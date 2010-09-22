class CandidateRenameOrderToPosition < ActiveRecord::Migration
  def self.up
    rename_column :candidates, :order, :position
  end

  def self.down
    rename_column :candidates, :position,:order
  end
end
