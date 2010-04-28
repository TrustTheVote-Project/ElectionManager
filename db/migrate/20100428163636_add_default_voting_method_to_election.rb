class AddDefaultVotingMethodToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :default_voting_method_id, :integer
  end

  def self.down
    remove_column :elections, :default_voting_method_id
  end
end
