class AddDistrictSetIdToAudit < ActiveRecord::Migration
  def self.up
    add_column :audits, :district_set_id, :integer
  end

  def self.down
    remove_column :audits, :district_set_id
  end
end
