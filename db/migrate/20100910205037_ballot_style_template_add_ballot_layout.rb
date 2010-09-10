class BallotStyleTemplateAddBallotLayout < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :ballot_layout, :text
  end

  def self.down
    remove_column :ballot_style_templates, :ballot_layout
  end
end
