class VideosController < ApplicationController
  def show
    #render text: params[:id]
    @video_id = params[:id]
  end
end
