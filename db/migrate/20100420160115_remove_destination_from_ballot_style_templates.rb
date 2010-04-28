class RemoveDestinationFromBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    remove_column :ballot_style_templates, :destination
  end

  def self.down
    add_column :ballot_style_templates, :destination
  end
end
