class BallotStyleTemplateAddBallotStyleFilename < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :ballot_style_file, :string
  end

  def self.down
    remove_column :ballot_style_templates, :ballot_style_file
  end
end
