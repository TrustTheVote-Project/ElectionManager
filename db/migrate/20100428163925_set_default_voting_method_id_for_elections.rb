class SetDefaultVotingMethodIdForElections < ActiveRecord::Migration
  def self.up
     change_column_default(:elections, :default_voting_method_id,0)
  end

  def self.down
    change_column_default(:elections, :default_voting_method_id,'')
  end
end
