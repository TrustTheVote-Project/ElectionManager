class AddStateSealImageToBallotStyleTemplate < ActiveRecord::Migration
  def self.up
    add_column :ballot_style_templates, :state_seal_image, :String
  end

  def self.down
    remove_column :ballot_style_templates, :state_seal_image
  end
end
