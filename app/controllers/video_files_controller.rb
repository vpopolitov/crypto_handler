class VideoFilesController < ApplicationController

  def show
    video = Video.find params[:video_id]
    file_name = params[:file_name]
    folder_id = video.google_drive_id
  
    drive = GoogleApiClient.get_drive
    res = GoogleApiClient.execute api_method: drive.files.list,
      parameters: { q: "'#{folder_id}' in parents and title = '#{file_name}'" }
      
    res = GoogleApiClient.execute uri: res.data.items.first.downloadUrl
    type = case File.extname(file_name)
      when '.m3u8'
        'application/x-mpegurl'
      when '.ts'
        'video/mp2t'
    end
    
    send_data res.body, type: type, disposition: 'inline'
  end

  def old_show
    video = Video.find_by title: params[:video_title]
    file_name = params[:file_name]
    video_file = VideoFile.find_by video_id: video.id, name: file_name
    google_disk_id = video_file.google_disk_id
    
    drive = GoogleApiClient.get_drive
    
    file_info = GoogleApiClient.execute api_method: drive.files.get, 
      parameters: { fileId: google_disk_id }
      
    res = GoogleApiClient.execute uri: file_info.data.download_url
    
    type = case File.extname(file_name)
      when '.m3u8'
        'application/x-mpegurl'
      when '.ts'
        'video/mp2t'
    end
    
    send_data res.body, type: type, disposition: 'inline'
  end



  require 'google/api_client'
  require 'typhoeus'
  
  CRYPTO_STORAGE_NAME = 'crypto-storage.json'
  SCOPE = 'https://www.googleapis.com/auth/drive'
  GOOGLE_GET_FILE_URL = 'https://www.googleapis.com/drive/v2/files/'
  
  def old_show
    video = Video.find_by title: params[:video_title]
    file_name = params[:file_name]
    video_file = VideoFile.find_by video_id: video.id, name: file_name
    google_disk_id = video_file.google_disk_id
    video_file_url = URI.join(GOOGLE_GET_FILE_URL, google_disk_id)
    
    logger.debug "will work with the following video file url: #{video_file_url}"
    
    typhoeus_request = Typhoeus::Request.new(
      video_file_url,
      headers: { Authorization: "Bearer #{access_token}" }
    )
    typhoeus_request.run
    file_info = JSON.parse(typhoeus_request.response.body)
    download_url = file_info['downloadUrl']
    logger.debug "will try to download by the following url: #{download_url}"
    
    type = case File.extname(file_name)
      when '.m3u8'
        'application/x-mpegurl'
      when '.ts'
        'video/mp2t'
    end

    typhoeus_request = Typhoeus::Request.new(
      download_url,
      headers: { Authorization: "Bearer #{access_token}" }
    )
    
    #typhoeus_request.on_headers do |res|
    #  if res.code < 200 && res.code >= 300
    #    raise "Request failed"
    #  end
    #end  
    #typhoeus_request.on_body do |chunk|
    #  response.stream.write chunk
    #end
    #typhoeus_request.on_complete do |response|
    #  response.stream.close
    #end
    typhoeus_request.run
    
    typhoeus_response = typhoeus_request.response
    logger.debug "file downloaded"
    send_data typhoeus_response.body, type: type, disposition: 'inline'
  end
  
  private
  
  def crypto_storage
    @crypto_storage ||= JSON.load(
      ENV["CRYPTO_STORAGE"] || File.open(Rails.root.join(CRYPTO_STORAGE_NAME)))
  end
  
  def access_token
    $stderr.puts ENV["ACCESS_TOKEN"].nil?
    $stderr.puts ENV["ACCESS_TOKEN"]
    $stderr.puts ENV.keys
    ENV["ACCESS_TOKEN"] ||= retrieve_access_token
  end
  
  def retrieve_access_token
    logger.debug 'retrieve access token'
    private_key  = crypto_storage['private_key']
    client_email = crypto_storage['client_email']
    pass_phrase  = crypto_storage['pass_phrase']

    key = OpenSSL::PKey::RSA.new private_key, pass_phrase
    logger.debug 'RSA key created'
    service_account = Google::APIClient::JWTAsserter.new(client_email, SCOPE, key)
        
    client = Google::APIClient.new
    client.authorization = service_account.authorize
    client_access_token = client.authorization.access_token
    
    logger.debug 'access token successfully retrieved'
    
    client_access_token
  end
end
