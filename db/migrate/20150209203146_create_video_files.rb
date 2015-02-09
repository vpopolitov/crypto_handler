class CreateVideoFiles < ActiveRecord::Migration
  def change
    create_table :video_files do |t|
      t.string :name
      t.text :download_url
      t.integer :video_id

      t.timestamps
    end
  end
end
