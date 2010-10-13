class CreateAssets < ActiveRecord::Migration
  def self.up
    create_table :assets do |t|
      t.string :ident
      t.string :kind
      t.string :file_name
      t.integer :file_size
      t.date_time :updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :assets
  end
end
