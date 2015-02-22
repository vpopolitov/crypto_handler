class Api::CategoriesController < Api::ApiController
  skip_before_filter :restrict_access

  def create
    #if @post.update_attributes(params[:post])
    #if Category.create(category_params)
    if true
      render json: Category.first, status: :ok
    else
      #render json: @post.errors, status: :unprocessable_entity
      render json: 'Error!', status: :unprocessable_entity
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

  private

  def category_params
    params.require(:category).permit(:title)
  end
end