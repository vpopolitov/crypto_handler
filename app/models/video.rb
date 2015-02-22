class Video < ActiveRecord::Base
  has_many :video_files
  belongs_to :category
end
