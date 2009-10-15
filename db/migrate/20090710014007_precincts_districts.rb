class PrecinctsDistricts < ActiveRecord::Migration
  def self.up
    create_table :districts_precincts, :id => false, :force => true do |t|
       t.integer "precinct_id"
       t.integer "district_id"
    end
  end

  def self.down
    drop_table :districts_precincts
  end
end
