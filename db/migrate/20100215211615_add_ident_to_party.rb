class AddIdentToParty < ActiveRecord::Migration
  def self.up
    add_column :parties, :ident, :string
    all_cand = Party.find(:all)
    all_cand.each do |party|
      party.ident = "party-#{party.id}"
      party.save!
    end
  end

  def self.down
    remove_column :parties, :ident
  end
end
