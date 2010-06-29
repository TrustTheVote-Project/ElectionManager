class CreateJurisdictionMemberships < ActiveRecord::Migration
  def self.up
     create_table :jurisdiction_memberships do |t|
       t.belongs_to :user
       t.belongs_to :district_set
       t.string :role, :default => 'standard'
       t.timestamps
     end
  end

  def self.down
    drop_table :jurisdiction_memberships
  end
end
