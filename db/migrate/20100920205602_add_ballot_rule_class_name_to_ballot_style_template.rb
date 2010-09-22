class AddBallotRuleClassNameToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :ballot_rule_classname, :string, :default => 'Default'
  end

  def self.down
    remove_column :ballot_style_templates, :ballot_rule_classname, :string
  end
end
