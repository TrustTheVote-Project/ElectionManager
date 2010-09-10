class CreatePrecinctSplits < ActiveRecord::Migration
  def self.up
    create_table :precinct_splits do |t|
      t.string :display_name
      t.integer :precinct_id
      t.integer :district_set_id

      t.timestamps
    end
  end

  def self.down
    drop_table :precinct_splits
  end
end
