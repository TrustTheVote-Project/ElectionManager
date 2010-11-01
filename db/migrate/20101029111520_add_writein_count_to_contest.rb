class AddWriteinCountToContest < ActiveRecord::Migration
  def self.up
    add_column :contests, :writein_count, :integer, :default => 1
  end

  def self.down
    remove_column :contests, :writein_count
  end
end
