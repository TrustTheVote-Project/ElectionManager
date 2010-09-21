class AddIndecesToDistrictSetDistricts < ActiveRecord::Migration
  def self.up
    add_index :district_sets_districts, :district_set_id
    add_index :district_sets_districts, :district_id
  end

  def self.down
    remove_index :district_sets_districts, :district_set_id
    remove_index :district_sets_districts, :district_id
  end
end
