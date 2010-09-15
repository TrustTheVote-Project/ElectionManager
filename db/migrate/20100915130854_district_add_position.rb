class DistrictAddPosition < ActiveRecord::Migration
  def self.up
    add_column :districts, :position, :integer, :default => 0    
  end

  def self.down
    remove_column :districts, :position
  end
end
