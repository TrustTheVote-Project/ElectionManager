class AddSomeIndexes < ActiveRecord::Migration
  def self.up
    add_index :precincts, :jurisdiction_id
    add_index :precinct_splits, :precinct_id
    add_index :contests, :election_id
    add_index :questions, :election_id
  end

  def self.down
    remove_index :precincts, :jurisdiction_id
    remove_index :precinct_splits, :precinct_id
    remove_index :contests, :election_id
    remove_index :questions, :election_id
  end
end
