class DropVideoFiles < ActiveRecord::Migration
  def up
    drop_table :video_files
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
