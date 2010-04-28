class AddDisplayNameToMedium < ActiveRecord::Migration
  def self.up
    add_column :media, :display_name, :string
  end

  def self.down
    remove_column :media, :display_name
  end
end
