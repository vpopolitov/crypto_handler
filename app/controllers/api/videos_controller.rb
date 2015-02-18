class Api::VideosController < Api::ApiController
  def create
    if Video.find_by title: video_params[:title], google_drive_id = video_params[:google_drive_id]
      Video.update(video_params)
    else
      Video.create(video_params)
    end
    head :no_content
  end
  
  private
  
  # { video: { title: '...', google_drive_id: '...' } }
  def video_params
    params.require(:video).permit(:title, :google_drive_id)
  end
end
