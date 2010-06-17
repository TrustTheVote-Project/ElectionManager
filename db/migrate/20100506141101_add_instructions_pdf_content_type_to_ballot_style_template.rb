class AddInstructionsPdfContentTypeToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :instructions_pdf_content_type, :string
  end

  def self.down
    remove_column :ballot_style_templates, :instructions_pdf_content_type
  end
end
