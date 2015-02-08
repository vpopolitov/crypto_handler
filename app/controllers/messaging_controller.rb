class MessagingController < ApplicationController
  include ActionController::Live
  
  require 'google/api_client'
  require 'typhoeus'
  
  CRYPTO_STORAGE_NAME = 'crypto-storage.json'
  FILES_ADDRESS = 'https://www.googleapis.com/drive/v2/files'
  SCOPE = 'https://www.googleapis.com/auth/drive'
  
  def send_message
    private_key  = crypto_storage['private_key']
    client_email = crypto_storage['client_email']
    pass_phrase  = crypto_storage['pass_phrase']

    key = OpenSSL::PKey::RSA.new private_key, pass_phrase    
    service_account = Google::APIClient::JWTAsserter.new(client_email, SCOPE, key)    
        
    client = Google::APIClient.new
    client.authorization = service_account.authorize
    access_token = client.authorization.access_token

    typhoeus_request = Typhoeus::Request.new(
      FILES_ADDRESS,
      headers: { Authorization: "Bearer #{access_token}" }
    )
    typhoeus_request.run
    typhoeus_response = typhoeus_request.response
    body = JSON.parse(typhoeus_response.body)
    file = body['items'].find { |i| i['title'] == 'inhibited-island.mp4' }
    
    typhoeus_request_headers = { Authorization: "Bearer #{access_token}" }
    start = params[:start]
    response.headers['Content-Type'] = 'video/mp4'
    
    if start
      file_size = file['fileSize'].to_i
      finish    = file_size - 1
      typhoeus_request_headers[:Range] = "bytes=#{start}-"
      response.headers['Content-Range']  = "bytes #{start}-#{finish}/#{file_size}"
      response.status = 206
    end

    typhoeus_request = Typhoeus::Request.new(
      file['downloadUrl'],
      headers: typhoeus_request_headers
    )

    typhoeus_request.on_headers do |res|
      if res.code < 200 && res.code >= 300
        raise "Request failed"
      end
    end  
    typhoeus_request.on_body do |chunk|
      response.stream.write chunk
    end
    typhoeus_request.on_complete do |response|
      response.stream.close
    end
    typhoeus_request.run
    
    #typhoeus_response = typhoeus_request.response
    #send_data typhoeus_response.body, type: 'video/mp4', disposition: 'inline'
  end
  
  private
  
  def crypto_storage
    @crypto_storage ||= JSON.load(
      ENV["CRYPTO_STORAGE"] || File.open(Rails.root.join(CRYPTO_STORAGE_NAME)))
  end
end
