class AddAuditIdToAlert < ActiveRecord::Migration
  def self.up
    add_column :alerts, :audit_id, :integer
  end

  def self.down
    remove_column :alerts, :audit_id
  end
end
