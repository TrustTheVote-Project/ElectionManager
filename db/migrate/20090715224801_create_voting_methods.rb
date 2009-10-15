class CreateVotingMethods < ActiveRecord::Migration
  def self.up
    create_table :voting_methods do |t|
      t.string :display_name

      t.timestamps
    end
  end

  def self.down
    drop_table :voting_methods
  end
end
