class Api::VideosController < Api::ApiController
  skip_before_filter :restrict_access

  def index
    #render json: Video.uncategorized.map { |i| { value: i.id, text: i.title, video: i } }, status: :ok
    render json: Video.uncategorized, each_serializer: VideoSerializer, root: false, status: :ok
  end

  def create
    if Video.find_by title: video_params[:title], google_drive_id: video_params[:google_drive_id]
      Video.update(video_params)
    else
      Video.create(video_params)
    end
    head :no_content
  end

  def update
    video = Video.find_by id: params[:id]
    if video && video.update(category_id: params[:category_id])
      #head :no_content
      render json: video, serializer: VideoSerializer, root: false, status: :ok
    else
      render json: 'Error!', status: :unprocessable_entity
    end
  end

  def destroy
    video = Video.find_by id: params[:id]
    if video
      video.update category_id: nil
      head :no_content
    else
      render json: 'Error!', status: :unprocessable_entity
    end
  end
  
  private
  
  # { video: { title: '...', google_drive_id: '...' } }
  def video_params
    params.require(:video).permit(:title, :google_drive_id)
  end
end
