require 'rake'

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

  
  desc "Create hls video, encrypt chunks, upload them to google disk and write info to db"
  task :upload, [:video_file, :video_name, :key_file] do |t, args|
    key_file = args[:key_file] || Rails.root.join(KEY_FILE_NAME)
    puts key_file
    
    # create hls video
    video_file = args[:video_file]
    puts FFMPEGC_CMD % {src_file_name: video_file}

    # encrypt chunks
    split_file_prefix = "stream"
    encrypted_split_file_prefix = "enc/#{split_file_prefix}"
    
    encryption_key = `cat #{key_file} | hexdump -e '16/1 \"%02x\"'`
    number_of_ts_files = `ls ${split_file_prefix}*.ts | wc -l`
    
    number_of_ts_files.times do |i|
      initialization_vector = '%032d' % i
      puts SSL_CMD % {split_file_prefix: split_file_prefix, encrypted_split_file_prefix: encrypted_split_file_prefix,
                      initialization_vector: initialization_vector, encryption_key: encryption_key, i: i}
    end
    
    # upload to google disk
    drive = GoogleApiClient.get_drive
    puts drive
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
