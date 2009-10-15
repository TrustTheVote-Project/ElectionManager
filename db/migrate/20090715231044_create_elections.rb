class CreateElections < ActiveRecord::Migration
  def self.up
    create_table :elections do |t|
      t.string :display_name
      t.integer :district_set_id
      t.datetime :start_date
      t.timestamps
    end
  end

  def self.down
    drop_table :elections
  end
end
