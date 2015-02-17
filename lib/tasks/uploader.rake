require 'rake'
require 'json'

class Trash < ActiveRecord::Base
end

class Storage
  class << self
    def [](name)
      storage.fetch(name) do |n|
        entry = Trash.find_by name: n
        storage[name] = JSON.parse(entry.value)
      end
    end
    
    def storage
      @storage ||= {}
    end
  end
end

namespace :uploader do
  KEY_FILE_NAME = 'video.key'
  
  FFMPEGC_CMD = <<-CMD
  ffmpeg -i %{src_file_name} -strict -2 -s 1280x720 -r 20 -vcodec h264 -acodec aac -ab 192000 -b:v 2580k -flags -global_header -map 0:0 -map 0:1 -f segment -segment_time 4 -segment_list_size 0 -segment_list list.m3u8 -segment_format mpegts stream%%d.ts
  CMD

  SSL_CMD = <<-CMD
  openssl aes-128-cbc -e -in %{split_file_prefix}%{i}.ts -out %{encrypted_split_file_prefix}%{i}.ts -nosalt -iv %{initialization_vector} -K %{encryption_key}
  CMD

  desc 'Sets up logging - should only be called from other rake tasks'
  task setup_logger: :environment do
    logger           = Logger.new(STDOUT)
    logger.level     = Logger::INFO
    Rails.logger     = logger
  end

  # before run task call smth like sudo mount -t vboxsf wind_temp ~/windows_share
  # run as rake uploader:upload['../test','~/windows_share/dest','big_buck_bunny.avi','test_folder']  
  desc 'Create hls video, encrypt chunks, upload them to google disk and write info to db'
  task :upload, [:working_dir, :dest_dir, :video_file, :video_name, :key_file] => :setup_logger do |t, args|
    working_dir = File.expand_path args[:working_dir]
    dest_dir    = File.expand_path args[:dest_dir]
    
    Rails.logger.info "Changing working directory to #{working_dir}"
    chdir working_dir
    
    video_name = args[:video_name]
    Rails.logger.info "Video name #{video_name}"
    key_file = args[:key_file] || Rails.root.join(KEY_FILE_NAME)
    Rails.logger.info "Key file #{key_file}"

    Rails.logger.info 'Starting creation of hls video'
    video_file = args[:video_file]
    system(FFMPEGC_CMD % {src_file_name: video_file})
    Rails.logger.info 'Creation of hls video finished'

    Rails.logger.info 'Starting chunks encryption'
    rm_rf 'enc' if Dir.exists? 'enc'
    mkdir 'enc'
    split_file_prefix = "stream"
    encrypted_split_file_prefix = "enc/#{split_file_prefix}"
    
    encryption_key = `cat #{key_file} | hexdump -e '16/1 \"%02x\"'`
    number_of_ts_files = `ls ${split_file_prefix}*.ts | wc -l`
    
    number_of_ts_files.to_i.times do |i|
      initialization_vector = '%032d' % i
      system(SSL_CMD % {split_file_prefix: split_file_prefix, encrypted_split_file_prefix: encrypted_split_file_prefix,
                       initialization_vector: initialization_vector, encryption_key: encryption_key, i: i})
    end
    Rails.logger.info 'Chunks encryption finished'
    
    Rails.logger.info 'Index m3u8 file moving to enc folder'
    mv 'list.m3u8', 'enc'
    
    Rails.logger.info 'Unencrypted chunks are deleted'
    rm Dir.glob('*.ts')
    
    dest_dir = File.join(dest_dir, video_name)
    rm_rf dest_dir if Dir.exists? dest_dir
    mkdir dest_dir
    Rails.logger.info "Starting files moving to #{dest_dir}"
    copy_entry 'enc', dest_dir
    remove_dir 'enc', force: true
    Rails.logger.info 'Files moving finished'
  end
  










  # run as rake uploader:upload['../test','big_buck_bunny.avi','test_folder']  
  desc 'Create hls video, encrypt chunks, upload them to google disk and write info to db'
  task :old_upload, [:working_dir, :video_file, :video_name, :key_file] => :setup_logger do |t, args|
    working_dir = args[:working_dir]
    Rails.logger.info "Changing working directory to #{working_dir}"
    chdir working_dir
    
    video_name = args[:video_name]
    Rails.logger.info "Video name #{video_name}"
    key_file = args[:key_file] || Rails.root.join(KEY_FILE_NAME)
    Rails.logger.info "Key file #{key_file}"
=begin 
    Rails.logger.info 'Starting creation of hls video'
    video_file = args[:video_file]
    system(FFMPEGC_CMD % {src_file_name: video_file})
    Rails.logger.info 'Creation of hls video finished'

    Rails.logger.info 'Starting chunks encryption'
    mkdir 'enc'
    split_file_prefix = "stream"
    encrypted_split_file_prefix = "enc/#{split_file_prefix}"
    
    encryption_key = `cat #{key_file} | hexdump -e '16/1 \"%02x\"'`
    number_of_ts_files = `ls ${split_file_prefix}*.ts | wc -l`
    
    result_files = []
    number_of_ts_files.to_i.times do |i|
      initialization_vector = '%032d' % i
      system(SSL_CMD % {split_file_prefix: split_file_prefix, encrypted_split_file_prefix: encrypted_split_file_prefix,
                       initialization_vector: initialization_vector, encryption_key: encryption_key, i: i})
      result_files << "#{encrypted_split_file_prefix}#{i}.ts"
    end
    Rails.logger.info 'Chunks encryption finished'
    
    Rails.logger.info 'Index m3u8 file copying'
    result_files = []
    cp 'list.m3u8', 'enc'
    result_files << 'enc/list.m3u8'
=end

=begin
    result_files = []
    131.times do |i|
      result_files << "enc/stream#{i}.ts"
    end
    result_files << 'enc/list.m3u8'
    
    Rails.logger.info 'Starting upload to google disk'
    result_hash = {files: {}}
    drive = GoogleApiClient.get_drive
    
    new_permission = drive.permissions.insert.request_schema.new({
      value: 'vadim.popolitov.test@gmail.com',
      type: 'user',
      role: 'writer'
    })

    file = drive.files.insert.request_schema.new({
      title: video_name,
      mimeType: 'application/vnd.google-apps.folder'
    })
    result = GoogleApiClient.execute(api_method: drive.files.insert, body_object: file)
    Rails.logger.info "Folder #{video_name} created"
    folder_id = result.data.id
    result_hash[video_name] = folder_id
    result = GoogleApiClient.execute(api_method: drive.permissions.insert, body_object: new_permission, parameters: {fileId: folder_id })
    Rails.logger.info "Folder shared"
    
    result_files.each do |result_file|
      mime_type = case File.extname(result_file)
        when '.m3u8'
          'application/x-mpegurl'
        when '.ts'
          'video/mp2t'
      end
      file = drive.files.insert.request_schema.new({
        title: result_file,
        mimeType: mime_type,
        parents: [{id: folder_id}]
      })
      Rails.logger.info "File #{result_file} reading"
      media = Google::APIClient::UploadIO.new(result_file, mime_type)
      
      Rails.logger.info "Starting file uploading"
      result = GoogleApiClient.execute(api_method: drive.files.insert, body_object: file,
        media: media, parameters: {uploadType: 'multipart', alt: 'json'})
      file_id = result.data.id
      result_hash[:files][File.basename(result_file)] = file_id
      result = GoogleApiClient.execute(api_method: drive.permissions.insert, body_object: new_permission, parameters: {fileId: file_id })
      Rails.logger.info "File uploading finished"
    end    
    
    puts result_hash.to_json
=end

    drive = GoogleApiClient.get_drive
=begin
    new_permission = drive.permissions.insert.request_schema.new({
      value: 'vadim.popolitov.test@gmail.com',
      type: 'user',
      role: 'writer'
    })
    result = GoogleApiClient.execute(api_method: drive.permissions.insert, body_object: new_permission, parameters: {fileId: '0B-8rPxoVszUTNGxVZXlwYUozTWs' })
    p result.data
=end
    
#    result = GoogleApiClient.execute(api_method: drive.files.list)
#    result.data.items.each { |i| puts i.title, i.id }
#    ids = result.data.items.map { |i| i.id }
#    p ids
#    ["0B-8rPxoVszUTcjJDTEdDcnAxa2c", "0B-8rPxoVszUTdlBRVEdQeVBPeDA", "0B-8rPxoVszUTVDlWMkpobjF2UTA", "0B-8rPxoVszUTTkx3bWJUcVR0NGM", "0B-8rPxoVszUTb1pZSmw5dF9vaVU", "0B-8rPxoVszUTV21PLWtST0d0ZU0", "0B-8rPxoVszUTemhPQ3RzMnI5SUU", "0B-8rPxoVszUTUnE4ZDQya1FpS28", "0B-8rPxoVszUTeVM0VndMZjRuOHc", "0B-8rPxoVszUTdG9LTnFhU21Zb1U", "0B-8rPxoVszUTOG1DT1ZIUEJjQWM", "0B-8rPxoVszUTZTJPVVZnb3pmM2M", "0B-8rPxoVszUTZTJBVEhzc2RFYU0", "0B-8rPxoVszUTbWtobnRrVXZhcEE", "0B-8rPxoVszUTQVVOT001Ulh0MWM", "0B-8rPxoVszUTNGljRlpaVHpXTzA", "0B-8rPxoVszUTZkQ1eUhlUVNnLVE", "0B-8rPxoVszUTbUx5bHZHOHlodk0", "0B-8rPxoVszUTV3RYVXVYdTNUSmc", "0B-8rPxoVszUTZkstMktLXy1nNU0", "0B-8rPxoVszUTcnpOM3pRV1VHbmc", "0B-8rPxoVszUTVGlkWmxaSVJINzQ", "0B-8rPxoVszUTN1dYX1lqY1F5dGs", "0B-8rPxoVszUTSTdNOF9GRVVRem8", "0B-8rPxoVszUTaXZ6eEIxYnJucHc", "0B-8rPxoVszUTQkJ6TXJjQmZfZUk", "0B-8rPxoVszUTNVZDUzFFMEJVVWc", "0B-8rPxoVszUTd0loNFVydy1sZGM", "0B-8rPxoVszUTSzJ1YXktLWFLd28", "0B-8rPxoVszUTS3BPWnN3aC1TRVU", "0B-8rPxoVszUTb2RuS2VYQTVmT3c", "0B-8rPxoVszUTS29xb05yaDFlSlE", "0B-8rPxoVszUTaUpleVhCUGtFNnc", "0B-8rPxoVszUTT0dMQ2hVYUhzS2s", "0B-8rPxoVszUTNEllRXF0d2tBMU0", "0B-8rPxoVszUTdkN6MWpBQ0I4VzA", "0B-8rPxoVszUTcmJhNDBBSkF6UVk", "0B-8rPxoVszUTemNnd2QxWW0tTWM", "0B-8rPxoVszUTNFRqbHZDTFVhUE0", "0B-8rPxoVszUTMkFpZFE1WmJBMDg", "0B-8rPxoVszUTWklITlBBMzdvOG8", "0B-8rPxoVszUTZS13cy1qU2ZzNm8", "0B-8rPxoVszUTckZRekEyOHdFckU", "0B-8rPxoVszUTS05tRFY0QjdKTnM", "0B-8rPxoVszUTSy1yQ3RTUEljMzA", "0B-8rPxoVszUTLS1nLWJNbEQzczg", "0B-8rPxoVszUTOGlQdFUxNHQ3UzA", "0B-8rPxoVszUTSWZxdGR0TzRaMDA", "0B-8rPxoVszUTdUlLRHhzdXViWjQ", "0B-8rPxoVszUTOGZ1ZFdQNjNHc2c", "0B-8rPxoVszUTYlIwMHVCSnpDblk", "0B-8rPxoVszUTdFJEcUh3blduQXM", "0B-8rPxoVszUTY1lTXzZDYzZEZDQ", "0B-8rPxoVszUTQnVJTmtaUjR1Y0k", "0B-8rPxoVszUTaUdCZjVMTUpVczg", "0B6SbkWXOHDMKc1B4R085dVhyMG8", "0B6SbkWXOHDMKOWFHQ1dRbnE1NE0", "0B6SbkWXOHDMKRTJ5RGduenhWXzg", "0B6SbkWXOHDMKaTI2NWhSOU1JU28", "0B6SbkWXOHDMKRVhhZ2ZEUTlqLWM", "0B6SbkWXOHDMKUy1BX3NzTUpMZm8", "0B6SbkWXOHDMKYUF6Yk5KQ1BZMXc", "0B6SbkWXOHDMKd3ZZbXN1V0pyTUE", "0B6SbkWXOHDMKT242aWhCdXU3VkE", "0B6SbkWXOHDMKTFZaTDFtbXBVanM", "0B6SbkWXOHDMKSHoxQ2hDdGZiS2c", "0B6SbkWXOHDMKQ1dKVF8zMjRwTFU", "0B6SbkWXOHDMKbVZNeVBYLXRodFk", "0B6SbkWXOHDMKRC0wUWMxcUlCYkE", "0B6SbkWXOHDMKZ0E2eWxOaF9xMEE", "0B6SbkWXOHDMKVGNWWnoyNXpTMk0", "0B6SbkWXOHDMKTndLcUoxZnVobFU", "0B-8rPxoVszUTc3RhcnRlcl9maWxl"]
#.each do |id|
#      result = GoogleApiClient.execute(api_method: drive.files.delete, parameters: { fileId: id })
#      puts 'deleted'
#    end

=begin
    start = Time.now
    folder_name = 'hls'
    file_name = '0.ts'
    res = GoogleApiClient.execute(api_method: drive.files.list, parameters: { q: "mimeType = 'application/vnd.google-apps.folder' and title = '#{folder_name}'" })
    folder_id = res.data.items.first.id
    res = GoogleApiClient.execute(api_method: drive.files.list, parameters: { q: "'#{folder_id}' in parents and title = '#{file_name}'" })
    puts Time.now - start
    puts res.data.items.first.downloadUrl
=end

=begin
    start = Time.now
    file_name = '0.ts'
    folder_id = '0B6SbkWXOHDMKSDg1aS0wQWhZaG8'
    res = GoogleApiClient.execute(api_method: drive.files.list, parameters: { q: "'#{folder_id}' in parents and title = '#{file_name}'" })
    puts Time.now - start
    puts res.data.items.first.downloadUrl
=end
    
    start = Time.now
    file_id = '0B6SbkWXOHDMKMDFXR0xzUzVaNWs'
    res = GoogleApiClient.execute(api_method: drive.files.get, parameters: { fileId: file_id })
    puts Time.now - start
    puts res.data

  end
  
  task :meas => :environment do
    puts 'start'
    start = Time.now
    (1..1_000).each do
      rnd = Random.new
      Storage['first']["trash #{rnd.rand(10_000)}"]
    end
    puts Time.now - start
    
    start = Time.now
    (1..1_000).each do
      rnd = Random.new
      Storage['first']["trash #{rnd.rand(10_000)}"]
    end
    puts Time.now - start
  end
end
