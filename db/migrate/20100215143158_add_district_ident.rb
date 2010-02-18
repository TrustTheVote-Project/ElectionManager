class AddDistrictIdent < ActiveRecord::Migration
  def self.up
    add_column :districts, :ident, :string
    all_dist = District.find(:all)
    all_dist.each do |dist|
      dist.ident = "dist-#{dist.id}"
      dist.save!
    end
  end

  def self.down
    remove_column :districts, :ident
  end
end
