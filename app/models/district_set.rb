# == Schema Information
# Schema version: 20100215144641
#
# Table name: district_sets
#
#  id             :integer         not null, primary key
#  display_name   :string(255)
#  secondary_name :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class DistrictSet < ActiveRecord::Base
  has_and_belongs_to_many :districts
  has_many :elections
  has_attached_file :icon, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  cattr_accessor :default
  
  @@default = nil
  
  # returns all precincts in this district set
  def precincts
    precinct_ids = connection.select_values( <<-eos
      SELECT DISTINCT districts_precincts.precinct_id
      FROM	districts_precincts, district_sets_districts
      WHERE	district_sets_districts.district_set_id = #{self.id}
      AND	district_sets_districts.district_id = districts_precincts.district_id
    eos
    )
    Precinct.find(precinct_ids)
  end
  
  # returns nil if default is already set, new default DistrictSet if not set
  def self.need_default
    return nil if @@default
    return @@default = DistrictSet.new(:display_name => "Default Jurisdiction") unless @@default
  end
  
end
