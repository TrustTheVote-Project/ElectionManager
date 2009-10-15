class CreateDistrictSetDistrict < ActiveRecord::Migration
  def self.up
    create_table :district_sets_districts, :id => false, :force => true do |t|
      t.integer "district_set_id"
      t.integer "district_id"
    end
  end

  def self.down
    drop_table :district_sets_districts
  end
end
