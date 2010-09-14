class BallotStyleTemplateAddBallotTitle < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :ballot_title, :string
  end

  def self.down
    remove_column :ballot_style_templates, :ballot_title
  end
end
