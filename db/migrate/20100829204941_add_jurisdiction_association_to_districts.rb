class AddJurisdictionAssociationToDistricts < ActiveRecord::Migration
  def self.up
    add_column :districts, :jurisdiction_id, :integer
  end

  def self.down
    remove_column :districts, :jurisdiction_id
  end
end
