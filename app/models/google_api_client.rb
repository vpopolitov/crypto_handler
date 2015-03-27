require 'forwardable'
require 'google/api_client'
require 'logger'

class GoogleApiClient
  extend SingleForwardable
  
  API_VERSION = 'v2'
  CACHED_API_FILE = "drive-#{API_VERSION}.cache"
  CRYPTO_STORAGE_NAME = 'crypto-storage.json'
  
  def_delegators :client, :execute, :execute!
  
  class << self
    def get_drive
      drive = nil
      if File.exists? cached_file
        logger.debug 'drive api from cache'
        File.open(cached_file) do |file|
          drive = Marshal.load(file)
        end
      else
        logger.debug 'drive api retrieving from server'
        drive = client.discovered_api('drive', API_VERSION)
        File.open(cached_file, 'w') do |file|
          Marshal.dump(drive, file)
        end
      end
      drive
    end
    
    def rewind
      @client = nil
    end

    def token
      logger.debug 'access token fetching'
      client.authorization.fetch_access_token!
      logger.debug 'access token fetched'
      client.authorization.access_token
    end
    
    private
    
    def client
      @client ||= get_client
    end
      
    def get_client
      private_key  = crypto_storage['private_key']
      client_email = crypto_storage['client_email']

      client = Google::APIClient.new(:application_name => 'Crypto handler',
          :application_version => '1.0.0')

      storage = ENV['AUTHORIZATION_STORAGE']
      if storage
        logger.debug 'client authorization from storage started'
        options = JSON.parse(storage)
        client.authorization = Signet::OAuth2::Client.new(options)
        logger.debug 'client authorization from storage completed'
      else
        logger.debug 'client authorization started'
        key = Google::APIClient::KeyUtils.load_key(private_key, 'notasecret') do |c, p|
          OpenSSL::PKey::RSA.new c, p
        end
        client.authorization = Signet::OAuth2::Client.new(
          :token_credential_uri => 'https://www.googleapis.com/oauth2/v3/token',
          :audience => 'https://www.googleapis.com/oauth2/v3/token',
          :scope => 'https://www.googleapis.com/auth/drive',
          :issuer => client_email,
          :signing_key => key)
        logger.debug 'access token fetching'
        client.authorization.fetch_access_token!
        logger.debug 'access token fetched'
        ENV['AUTHORIZATION_STORAGE'] = client.authorization.to_json
        logger.debug 'client authorization completed'
      end
      
      client
    end
    
    def crypto_storage
      @crypto_storage ||= JSON.load(
        ENV["CRYPTO_STORAGE"] || File.open(Rails.root.join(CRYPTO_STORAGE_NAME)))
    end
    
    def cached_file
      Rails.root.join(CACHED_API_FILE)
    end
  end
end