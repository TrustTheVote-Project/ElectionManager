class AddIdentToElection < ActiveRecord::Migration
  def self.up
    add_column :elections, :ident, :string
    
    all_elec = Election.find(:all)
    all_elec.each do |elec|
      elec.ident = "elec-#{elec.id}"
      elec.save!
    end
  end

  def self.down
    remove_column :elections, :ident
  end
end
