require 'digest'
require 'json'

class VideosController < ApplicationController
  before_action :check_access_code, only: :show

  def show
    @video_id = params[:id]
    render layout: false
  end

  def new_session
  end

  def create_session
    video = Video.find_by access_code: params[:session][:access_code]
    if video
      video_sign_in video
      redirect_to video_path(video)
    else
      flash.now[:error] = "Неправильный код доступа"
      render 'new_session'
    end
  end

  private

  def video_sign_in(video)
    cookies.signed[access_code_cookie_name(video.id)] = {
        value: video.id.to_s,
        expires: 1.hour.from_now,
        httponly: true
    }
  end

  def video_access_provided?
    cookies.signed[access_code_cookie_name(params[:id])] == params[:id]
  end

  def check_access_code
    redirect_to new_session_for_videos_path, notice: "Введите код доступа" unless video_access_provided?
  end

  def access_code_cookie_name(id)
    "access_code_token_#{Digest::SHA256.hexdigest(id.to_s)}"
  end
end
