class CreateBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    create_table :ballot_style_templates do |t|
      t.string :display_name
      t.integer :default_voting_method
      t.text :instruction_text
      t.string :state_graphic

      t.timestamps
    end
  end

  def self.down
    drop_table :ballot_style_templates
  end
end
