class CreateUserRoles < ActiveRecord::Migration
  def self.up
    create_table :user_roles do |t|
      t.belongs_to :user
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :user_roles
  end
end
