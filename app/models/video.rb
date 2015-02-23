class Video < ActiveRecord::Base
  has_many :video_files
  belongs_to :category

  scope :uncategorized, -> { where(category_id: nil) }
end
