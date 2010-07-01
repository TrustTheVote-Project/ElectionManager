class AddDescriptiveTextToDistrictSet < ActiveRecord::Migration
  def self.up
    add_column :district_sets, :descriptive_text,    :string
  end

  def self.down
    remove_column :district_sets, :descriptive_text
  end
end
