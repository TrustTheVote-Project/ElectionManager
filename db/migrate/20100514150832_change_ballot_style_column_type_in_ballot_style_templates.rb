class ChangeBallotStyleColumnTypeInBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    change_column :ballot_style_templates, :ballot_style, :integer
  end

  def self.down
    change_column :ballot_style_templates, :ballot_style, :string
  end
end
