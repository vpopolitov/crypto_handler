require "rails-api"

class Api::ApiController < ActionController::API
  include SessionsHelper
  include ActionController::Cookies

  before_action :restrict_access

  private

  def restrict_access
    head status: :unauthorized unless signed_in?
  end
end
