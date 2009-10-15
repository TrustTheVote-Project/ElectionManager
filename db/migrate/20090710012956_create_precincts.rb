class CreatePrecincts < ActiveRecord::Migration
  def self.up
    create_table :precincts do |t|
      t.string :display_name

      t.timestamps
    end
  end

  def self.down
    drop_table :precincts
  end
end
