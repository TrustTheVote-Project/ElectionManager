class RenameInstructionsPdfFileSizeToInstructionsImageFileSizeInBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    rename_column :ballot_style_templates, :instructions_pdf_file_size, :instructions_image_file_size
  end

  def self.down
    rename_column :ballot_style_templates, :instructions_image_file_size, :instructions_pdf_file_size
  end
end
