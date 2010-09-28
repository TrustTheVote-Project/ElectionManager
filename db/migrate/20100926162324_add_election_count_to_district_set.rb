class AddElectionCountToDistrictSet < ActiveRecord::Migration
  def self.up
    add_column :district_sets, :elections_count, :integer    
  end

  def self.down
    remove_column :district_sets, :elections_count
  end
end
