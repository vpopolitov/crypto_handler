class Api::CategoriesController < Api::ApiController
  skip_before_action :restrict_access, only: :index
  after_action :add_signed_in, only: :index

  def index
    categories = Category.eager_load(:videos).order('videos.id').all
    #render json: { categories: categories.as_json(include: :videos) }, status: :ok
    render json: categories, each_serializer: CategorySerializer, meta: { signed_in: signed_in? }, status: :ok
  end

  def create
    #if @post.update_attributes(params[:post])
    category = Category.create(category_params)
    if category
      render json: category, serializer: CategorySerializer, root: false, status: :ok
    else
      #render json: @post.errors, status: :unprocessable_entity
      render json: 'Error!!!', status: :unprocessable_entity
    end
  end

  def update
    category = Category.find_by id: params[:id]
    if category && category.update(category_params)
      head :no_content
    else
      render json: 'Error!', status: :unprocessable_entity
    end
  end

  def destroy
    category = Category.find_by id: params[:id]
    if category
      category.destroy
      Video.where(category_id: category.id).update_all(category_id: nil)
      head :no_content
    else
      render json: 'Error!', status: :unprocessable_entity
    end
  end

  private

  def category_params
    params.require(:category).permit(:title)
  end

  def add_signed_in
    2
  end
end