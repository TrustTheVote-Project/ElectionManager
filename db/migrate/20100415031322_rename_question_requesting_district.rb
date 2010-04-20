class RenameQuestionRequestingDistrict < ActiveRecord::Migration
  def self.up
    remove_column :questions, :district_id
    add_column :questions, :requesting_district_id, :integer
  end

  def self.down
    remove_column :questions, :requesting_district_id
    add_column :questions, :district_id, :integer

  end
end
