class AddSecondaryNameToDistrictSets < ActiveRecord::Migration
  def self.up
    add_column :district_sets, :secondary_name, :string
  end

  def self.down
    remove_column :district_sets, :secondary_name
  end
end
