class Api::CategoriesController < Api::ApiController
  skip_before_filter :restrict_access

  def index
    categories = Category.eager_load(:videos).order('videos.id').all
    render json: { categories: categories.as_json(include: :videos) }, status: :ok
  end

  def create
    #if @post.update_attributes(params[:post])
    category = Category.create(category_params)
    if category
      render json: category, status: :ok
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
end