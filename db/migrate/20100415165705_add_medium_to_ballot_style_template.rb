class AddMediumToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :medium_id, :integer
  end

  def self.down
    remove_column :ballot_style_templates, :medium_id
  end
end
