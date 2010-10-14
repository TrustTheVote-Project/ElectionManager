class AddJurisdLogoToDistrictset < ActiveRecord::Migration
  def self.up
    add_column :district_sets, :logo_ident, :string
  end

  def self.down
    remove_column :district_sets, :logo_ident
  end
end
