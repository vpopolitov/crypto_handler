require 'rake'
require 'json'
require 'faraday'

namespace :uploader do
  KEY_FILE_NAME = 'video.key'
  
  FFMPEGC_CMD = <<-CMD
  ffmpeg -i %{src_file_name} -s 854x480 -c:v libx264 -b:v 1400k -bf 2 -keyint_min 24 -g 72 -sc_threshold 0 -c:a aac -strict experimental -b:a 96k -ar 32000 -r 24 out.mp4
  CMD

  ENCRYPT_CMD = <<-CMD
  MP4Box -crypt %{key_file} out.mp4 -out out_encrypted.mp4
  CMD

  DASH_CMD = <<-CMD
  MP4Box -dash 12000 -rap -bs-switching no -sample-groups-traf -profile onDemand out_encrypted.mp4#audio out_encrypted.mp4#video
  CMD
  
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

    Rails.logger.info 'Starting creation a mp4 file with needed bitrate'
    video_file = args[:video_file]
    system(FFMPEGC_CMD % {src_file_name: video_file})
    Rails.logger.info 'Creation of mp4 video finished'

    Rails.logger.info 'Starting mp4 file encryption'
    system(ENCRYPT_CMD % {key_file: key_file})
    Rails.logger.info 'Mp4 file encryption finished'
    
    Rails.logger.info 'Making a dash file'
    system(DASH_CMD)
    Rails.logger.info 'A dash file created'
    
    dest_dir = File.join(dest_dir, video_name)
    rm_rf dest_dir if Dir.exists? dest_dir
    mkdir dest_dir
    Rails.logger.info "Starting files moving to #{dest_dir}"
    remove %W( #{video_file} out.mp4 out_encrypted.mp4 )
    copy_entry '.', dest_dir
    Rails.logger.info 'Files moving finished'
  end
  
  # run remotely as rake uploader:db_update["мульт\ про\ кролика"]
  desc 'Go to Google disk, search video folder by name and write folder id to db'
  task :db_update, [:video_name] => :setup_logger do |_, args|
    video_name = args[:video_name]

    Rails.logger.info 'Start fetching folder id by name'
    drive = GoogleApiClient.get_drive
    google_res = GoogleApiClient.execute(
        api_method: drive.files.list,
        parameters: { q: "mimeType = 'application/vnd.google-apps.folder' and title = '#{video_name}'" })
    folder_id = google_res.data.items.first.id    
    Rails.logger.info 'Folder id is taken. Write to db'

    video = Video.new title: video_name, google_drive_id: folder_id
    video.access_code = (('a'..'z').to_a + (0..9).to_a).shuffle[0..5].join
    video.save!
    Rails.logger.info 'Info is inserted to db'
  end
end
