class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.string :display_name
      t.integer :open_seat_count
      t.integer :voting_method_id
      t.integer :district_id
      t.integer :election_id

      t.timestamps
    end
  end

  def self.down
    drop_table :contests
  end
end
