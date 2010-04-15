# == Schema Information
# Schema version: 20100215144641
#
# Table name: precincts
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  ident        :string(255)
#

class Precinct < ActiveRecord::Base
  
  has_and_belongs_to_many :districts
  
  attr_accessor :importId # for xml import, hacky could do this by dynamically extending class at runtime
  
  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique Precinct ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "prec-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
  
  

  def districts(districtSet)
    district_ids = connection.select_values( <<-eos
       SELECT DISTINCT districts_precincts.district_id
       FROM	districts_precincts, district_sets_districts
       WHERE district_sets_districts.district_set_id = #{districtSet.id}
       AND district_sets_districts.district_id = districts_precincts.district_id	
       AND	districts_precincts.precinct_id = #{self.id}
     eos
     )
    District.find(district_ids)
  end
end
