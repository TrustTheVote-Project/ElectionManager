class RenameInstructionsPdfContentTypeToInstructionsImageContentTypeInBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    rename_column :ballot_style_templates, :instructions_pdf_content_type, :instructions_image_content_type
  end

  def self.down
    rename_column :ballot_style_templates, :instructions_image_content_type, :instructions_pdf_content_type
  end
end
