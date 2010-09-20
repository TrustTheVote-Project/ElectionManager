class AddPositionToQuestion < ActiveRecord::Migration
  def self.up
    add_column :questions, :position, :integer, :default => 0    
  end

  def self.down
    remove_column :questions, :position
  end
end
