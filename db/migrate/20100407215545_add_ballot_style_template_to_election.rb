class AddBallotStyleTemplateToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :ballot_style_template_id, :integer
  end

  def self.down
    remove_column :elections, :ballot_style_template_id
  end
end
