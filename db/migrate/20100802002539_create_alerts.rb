class CreateAlerts < ActiveRecord::Migration
  def self.up
    create_table :alerts do |t|
      t.string :display_name
      t.string :type
      t.string :message
      t.text :objects
      t.text :options # Serialized hash
      t.text :choice
      t.text :default_option
      t.timestamps
    end
  end

  def self.down
    drop_table :alerts
  end
end
