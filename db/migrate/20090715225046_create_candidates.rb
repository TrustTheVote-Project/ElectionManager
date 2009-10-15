class CreateCandidates < ActiveRecord::Migration
  def self.up
    create_table :candidates do |t|
      t.string :display_name
      t.integer :party_id
      t.integer :contest_id

      t.timestamps
    end
  end

  def self.down
    drop_table :candidates
  end
end
