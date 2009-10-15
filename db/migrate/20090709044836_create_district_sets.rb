class CreateDistrictSets < ActiveRecord::Migration
  def self.up
    create_table :district_sets do |t|
      t.string :display_name

      t.timestamps
    end
  end

  def self.down
    drop_table :district_sets
  end
end
