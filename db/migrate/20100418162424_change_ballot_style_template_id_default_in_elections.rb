class ChangeBallotStyleTemplateIdDefaultInElections < ActiveRecord::Migration
  def self.up
     change_column_default(:elections, :ballot_style_template_id,0)
  end

  def self.down
    change_column_default(:elections, :ballot_style_template_id,'')
  end
end
