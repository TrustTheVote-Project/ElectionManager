class CreateDistrictTypes < ActiveRecord::Migration
  def self.up
    create_table :district_types do |t|
      t.string :title

      t.timestamps
    end
  end

  def self.down
    drop_table :district_types
  end
end
