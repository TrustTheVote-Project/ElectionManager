class AddBallotStyleToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :ballot_style, :string
  end

  def self.down
    remove_column :ballot_style_templates, :ballot_style
  end
end
