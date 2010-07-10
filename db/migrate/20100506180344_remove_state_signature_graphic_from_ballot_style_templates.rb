class RemoveStateSignatureGraphicFromBallotStyleTemplates < ActiveRecord::Migration
  def self.up
    remove_column :ballot_style_templates, :state_signature_graphic
    
  end

  def self.down
    add_column :ballot_style_templates, :state_signature_graphic
  end
end