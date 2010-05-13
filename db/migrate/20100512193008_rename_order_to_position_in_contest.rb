class RenameOrderToPositionInContest < ActiveRecord::Migration
  def self.up
    remove_column :contests, :order
    add_column :contests, :position, :integer, :default => 0
  end

  def self.down
    remove_column :contests, :position, :default => 0
    add_column :contests, :order, :integer
  end
end