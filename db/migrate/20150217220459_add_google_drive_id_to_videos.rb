class AddGoogleDriveIdToVideos < ActiveRecord::Migration
  def change
    add_column :videos, :google_drive_id, :string
  end
end
