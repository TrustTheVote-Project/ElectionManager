class AddCandidateOrder < ActiveRecord::Migration
  def self.up
    add_column :candidates, :order, :integer, :default => 0
  end

  def self.down
    remove_column :candidates, :order
  end
end
