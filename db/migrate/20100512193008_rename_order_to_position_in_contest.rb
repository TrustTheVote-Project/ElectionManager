class RenameOrderToPositionInContest < ActiveRecord::Migration
  def self.up
    remove_column :contests, :order
    add_column :contests, :position, :integer
  end

  def self.down
    remove_column :contests, :position
    add_column :contests, :order, :integer
  end
end