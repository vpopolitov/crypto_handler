require "rails-api"

class Api::ApiController < ActionController::API
  include SessionsHelper
  include ActionController::Cookies

  before_action :restrict_access

  private

  def restrict_access
    head status: :unauthorized unless signed_in?
  end

  def video_access_provided?
    cookies.signed[access_code_cookie_name(params[:id])] == params[:id]
  end

  def check_access_code
    head :unauthorized unless video_access_provided?
  end

  def access_code_cookie_name(id)
    "access_code_token_#{Digest::SHA256.hexdigest(id.to_s)}"
  end

  def cors_set_access_control_headers
    headers['Access-Control-Allow-Origin'] = '*'
    headers['Access-Control-Allow-Methods'] = 'POST, GET, PUT, DELETE, OPTIONS'
    headers['Access-Control-Allow-Headers'] = 'Origin, Content-Type, Accept, Authorization, Token'
  end
end
