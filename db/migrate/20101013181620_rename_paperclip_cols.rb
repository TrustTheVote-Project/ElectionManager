class RenamePaperclipCols < ActiveRecord::Migration
  def self.up
    rename_column :assets, :file_name, :asset_file_name
    rename_column :assets, :file_size, :asset_file_size
    add_column :assets, :asset_updated_at, :datetime
    add_column :assets, :asset_content_type, :string
  end

  def self.down
    rename_column :assets, :asset_file_name, :file_name 
    rename_column :assets,:asset_file_size,  :file_size
    remove_column :assets, :asset_updated_at
    remove_column :assets, :asset_content_type
  end
end
