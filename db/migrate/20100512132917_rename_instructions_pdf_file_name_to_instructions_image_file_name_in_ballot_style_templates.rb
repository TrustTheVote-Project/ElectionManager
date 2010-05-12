class RenameInstructionsPdfFileNameToInstructionsImageFileNameInBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    rename_column :ballot_style_templates, :instructions_pdf_file_name, :instructions_image_file_name
    
  end

  def self.down
    rename_column :ballot_style_templates, :instructions_image_file_name, :instructions_pdf_file_name
  end
end
