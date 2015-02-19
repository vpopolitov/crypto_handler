require 'rake'
require 'json'
require 'faraday'

namespace :uploader do
  KEY_FILE_NAME = 'video.key'
  
  FFMPEGC_CMD = <<-CMD
  ffmpeg -i %{src_file_name} -strict -2 -s 1280x720 -r 20 -vcodec h264 -acodec aac -ab 192000 -b:v 2580k -flags -global_header -map 0:0 -map 0:1 -f segment -segment_time 4 -segment_list_size 0 -segment_list list.m3u8 -segment_format mpegts stream%%d.ts
  CMD

  SSL_CMD = <<-CMD
  openssl aes-128-cbc -e -in %{split_file_prefix}%{i}.ts -out %{encrypted_split_file_prefix}%{i}.ts -nosalt -iv %{initialization_vector} -K %{encryption_key}
  CMD
  
  API_UPDATE_URL = "#{ENV['APP_URL']}/api/videos"

  desc 'Sets up logging - should only be called from other rake tasks'
  task setup_logger: :environment do
    logger           = Logger.new(STDOUT)
    logger.level     = Logger::INFO
    Rails.logger     = logger
  end

  # before run task call smth like sudo mount -t vboxsf -o rw,uid=1000,gid=1000,dmode=755,fmode=644 wind_temp ~/windows_share
  # run as rake uploader:upload['../test','~/windows_share/google_drive/video','big_buck_bunny.avi','мульт про кролика']
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
    insert_key('list.m3u8', key_file)
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
  
  # run as APP_URL='http://stormy-coast-4639.herokuapp.com' rake uploader:db_update["мульт\ про\ кролика"]
  desc 'Go to Google disk, search video folder by name and write folder id to db'
  task :db_update, [:video_name] => :setup_logger do |t, args|
    video_name = args[:video_name]

    Rails.logger.info 'Start fetching folder id by name'
    drive = GoogleApiClient.get_drive
    google_res = GoogleApiClient.execute(api_method: drive.files.list, parameters: { q: "mimeType = 'application/vnd.google-apps.folder' and title = '#{video_name}'" })
    folder_id = google_res.data.items.first.id    
    Rails.logger.info 'Folder id is taken. Write to db'
    
    api_access_token = Rails.application.secrets.api_access_token
    res = Faraday.new.post API_UPDATE_URL do |req|
      req.headers['Authorization'] = "Token token=#{api_access_token}"
      req.body = {video: { title: video_name, google_drive_id: folder_id }}
    end
    Rails.logger.info 'Info is inserted to db'
  end
  
  def insert_key(meta_file, key_file_path)
    key_file_name = File.basename(key_file_path)
    text = File.read(meta_file)
    text.sub!(
      %Q{#EXT-X-ALLOW-CACHE:YES},
      %Q{#EXT-X-ALLOW-CACHE:YES
#EXT-X-KEY:METHOD=AES-128,URI="/#{key_file_name}"}
    )
    File.open(meta_file, "w") { |f| f.puts text }
  end
end
