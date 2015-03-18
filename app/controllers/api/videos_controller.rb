class Api::VideosController < Api::ApiController
  skip_before_filter :restrict_access, only: [:map, :token]
  before_action :check_access_code, only: [:map, :token]

  def index
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

  def map
    video = Video.find params[:id]
    folder_id = video.google_drive_id

    token = GoogleApiClient.token

    drive = GoogleApiClient.get_drive
    res = GoogleApiClient.execute api_method: drive.files.list, parameters: { q: "'#{folder_id}' in parents" }
    hash = res.data.items.map do |i|
      { downloadUrl: i.downloadUrl, originalFilename: i.originalFilename }
    end

    render json: { mapping: hash, access_token: token }, status: :ok
  end

  def token
    render json: { access_token: GoogleApiClient.token }, status: :ok
  end
  
  private
  
  # { video: { title: '...', google_drive_id: '...' } }
  def video_params
    params.require(:video).permit(:title, :google_drive_id)
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
end
