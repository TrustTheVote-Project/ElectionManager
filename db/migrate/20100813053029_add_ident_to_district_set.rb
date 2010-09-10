class AddIdentToDistrictSet < ActiveRecord::Migration
  def self.up
    add_column :district_sets, :ident, :string
    
    all_juris = DistrictSet.find(:all)
    all_juris.each do |juris|
      juris.ident = "juris-#{juris.id}"
      juris.save!
    end
  end

  def self.down
    remove_column :district_sets, :ident
  end
end
