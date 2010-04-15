class AddDestinationToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :destination, :string
  end

  def self.down
    remove_column :ballot_style_templates, :destination
  end
end
