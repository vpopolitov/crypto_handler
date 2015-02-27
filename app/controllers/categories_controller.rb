class CategoriesController < ApplicationController
  def index
    @categories = Category.eager_load(:videos).order('videos.id').all
  end
end
