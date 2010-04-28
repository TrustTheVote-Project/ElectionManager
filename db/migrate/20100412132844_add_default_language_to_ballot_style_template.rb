class AddDefaultLanguageToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :default_language, :integer
  end

  def self.down
    remove_column :ballot_style_templates, :default_language
  end
end
