class AddInstructionsPdfFileNameToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :instructions_pdf_file_name, :string
  end

  def self.down
    remove_column :ballot_style_templates, :instructions_pdf_file_name
  end
end
