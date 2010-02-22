class AddContestOrder < ActiveRecord::Migration
 def self.up
    add_column :contests, :order, :integer, :default => 0
  end

  def self.down
    remove_column :contests, :order
  end
end
