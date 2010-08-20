class DropDistrictsPrecinctAssoc < ActiveRecord::Migration
  def self.up
    drop_table :districts_precincts
  end

  def self.down
    create_table "districts_precincts", :id => false, :force => true do |t|
      t.integer :precinct_id
      t.integer :district_id
    end
  end
end
