class VideoFilesController < ApplicationController
  require 'google/api_client'
  require 'typhoeus'
  
  CRYPTO_STORAGE_NAME = 'crypto-storage.json'
  SCOPE = 'https://www.googleapis.com/auth/drive'
  
  def show
    video = Video.find_by title: params[:video_title]
    file_name = params[:file_name]
    video_file = VideoFile.find_by video_id: video.id, name: file_name
    url = video_file.download_url
    
    private_key  = crypto_storage['private_key']
    client_email = crypto_storage['client_email']
    pass_phrase  = crypto_storage['pass_phrase']

    key = OpenSSL::PKey::RSA.new private_key, pass_phrase    
    service_account = Google::APIClient::JWTAsserter.new(client_email, SCOPE, key)    
        
    client = Google::APIClient.new
    client.authorization = service_account.authorize
    access_token = client.authorization.access_token

    typhoeus_request = Typhoeus::Request.new(
      url,
      headers: { Authorization: "Bearer #{access_token}" }
    )
    
    typhoeus_request.on_headers do |res|
      if res.code < 200 && res.code >= 300
        raise "Request failed"
      end
    end  
    #typhoeus_request.on_body do |chunk|
    #  response.stream.write chunk
    #end
    #typhoeus_request.on_complete do |response|
    #  response.stream.close
    #end
    typhoeus_request.run
    
    typhoeus_response = typhoeus_request.response
    type = case File.extname(file_name)
      when '.m3u8'
        'application/x-mpegurl'
      when '.ts'
        'video/mp2t'
    end
    send_data typhoeus_response.body, type: type, disposition: 'inline'
  end
  
  private
  
  def crypto_storage
    @crypto_storage ||= JSON.load(
      ENV["CRYPTO_STORAGE"] || File.open(Rails.root.join(CRYPTO_STORAGE_NAME)))
  end
end
