class AddCategoryToVideos < ActiveRecord::Migration
  def change
    add_reference :videos, :category
  end
end
