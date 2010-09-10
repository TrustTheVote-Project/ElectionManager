class AuditModelChange < ActiveRecord::Migration
  def self.up
    add_column :audits, :content_type, :string
  end

  def self.down
    remove_column :audits, :content_type
  end
end
