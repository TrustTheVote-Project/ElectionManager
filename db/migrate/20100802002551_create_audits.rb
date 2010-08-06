class CreateAudits < ActiveRecord::Migration
  def self.up
    create_table :audits do |t|
      t.string :display_name
      t.text :election_data_hash
      t.timestamps
    end
  end

  def self.down
    drop_table :audits
  end
end
