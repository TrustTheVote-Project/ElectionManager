class RemovePaperclipFromDistrictset < ActiveRecord::Migration
  def self.up
    remove_column :district_sets, :icon_file_name
    remove_column :district_sets, :icon_content_type
    remove_column :district_sets, :icon_file_size
    remove_column :district_sets, :icon_updated_at
  end

  def self.down
    add_column :district_sets, :icon_file_name, :string
    add_column :district_sets, :icon_content_type, :string
    add_column :district_sets, :icon_file_size, :integer
    add_column :district_sets, :icon_updated_at, :datetime
  end
end
