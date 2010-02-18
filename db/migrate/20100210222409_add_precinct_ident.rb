class AddPrecinctIdent < ActiveRecord::Migration
  def self.up
    add_column :precincts, :ident, :string
    Precinct.update_all("ident = 'prec-' || id ")
  end

  def self.down
    remove_column :precincts, :ident
  end
end
