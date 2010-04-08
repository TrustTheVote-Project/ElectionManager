class AddLanguageToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :language, :string
  end

  def self.down
    remove_column :ballot_style_templates, :language
  end
end
