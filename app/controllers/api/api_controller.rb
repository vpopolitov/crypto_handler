require "rails-api"

class Api::ApiController < ActionController::API
  include ActionController::HttpAuthentication::Token::ControllerMethods
  
  before_filter :restrict_access

  private
  
  def restrict_access
    authenticate_or_request_with_http_token do |token, _|
      puts token
      puts Rails.application.secrets.api_access_token
      Rails.application.secrets.api_access_token == token
    end
  end
end
