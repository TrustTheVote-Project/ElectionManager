class AddInstructionsPdfFileSizeToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :instructions_image_file_size, :string
  end

  def self.down
    remove_column :ballot_style_templates, :instructions_image_file_size
  end
end
