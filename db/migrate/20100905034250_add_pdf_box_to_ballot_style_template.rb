class AddPdfBoxToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :page, :text
    add_column :ballot_style_templates, :frame, :text
    add_column :ballot_style_templates, :contents, :text
  end

  def self.down
    remove_column :ballot_style_templates, :page
    remove_column :ballot_style_templates, :frame
    remove_column :ballot_style_templates, :contents
  end
end
