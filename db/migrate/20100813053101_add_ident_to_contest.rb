class AddIdentToContest < ActiveRecord::Migration
  def self.up
    add_column :contests, :ident, :string
    
    all_cont = Contest.find(:all)
    all_cont.each do |cont|
      cont.ident = "cont-#{cont.id}"
      cont.save!
    end
  end

  def self.down
    remove_column :contests, :ident
  end
end
