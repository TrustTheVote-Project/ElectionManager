class CreateBallots < ActiveRecord::Migration
  def self.up
    create_table :ballots do |t|
      t.belongs_to :election
      t.belongs_to :precinct_split

      t.timestamps
    end
  end

  def self.down
    drop_table :ballots
  end
end
