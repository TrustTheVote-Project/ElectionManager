class AddDisplayNameToAsset < ActiveRecord::Migration
  def self.up
    add_column :assets, :display_name,    :string
  end

  def self.down
    remove_column :assets, :display_name
  end
end
