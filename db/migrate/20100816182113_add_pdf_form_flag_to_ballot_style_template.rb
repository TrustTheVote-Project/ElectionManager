class AddPdfFormFlagToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :pdf_form, :boolean
  end

  def self.down
    remove_column :ballot_style_templates, :pdf_form
  end
end
