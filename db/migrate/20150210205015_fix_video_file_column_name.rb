class FixVideoFileColumnName < ActiveRecord::Migration
  def change
    rename_column :video_files, :download_url, :google_disk_id
    change_column :video_files, :google_disk_id, :string
  end
end
