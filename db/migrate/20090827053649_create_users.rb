class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :email
      t.string :crypted_password
      t.string :password_salt
      t.string :persistence_token
      t.string :perishable_token
      t.integer :failed_login_count

      t.timestamps
    end
    add_index :users, :perishable_token
  end

  def self.down
    drop_table :users
  end
end
