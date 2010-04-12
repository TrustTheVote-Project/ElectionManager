class RemoveLanguageFromBallotStyleTemplates < ActiveRecord::Migration
  def self.up
      remove_column :ballot_style_templates, :language
    end

    def self.down
      add_column :ballot_style_templates, :language
    end
end
