class AddJurisdictionAssociationToPrecinct < ActiveRecord::Migration
  def self.up
    add_column :precincts, :jurisdiction_id, :integer
  end

  def self.down
    remove_column :precincts, :jurisdiction_id
  end
end
