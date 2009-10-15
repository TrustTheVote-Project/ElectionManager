class CreateDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts do |t|
      t.integer :district_type_id
      t.string :display_name

      t.timestamps
    end
  end

  def self.down
    drop_table :districts
  end
end
