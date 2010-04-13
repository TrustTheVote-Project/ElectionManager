class AddStateSignatureImageToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :state_signature_image, :String
  end

  def self.down
    remove_column :ballot_style_templates, :state_signature_image
  end
end
