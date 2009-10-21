class Precinct < ActiveRecord::Base
  has_and_belongs_to_many :districts
  
  attr_accessor :importId # for xml import, hacky could do this by dynamically extending class at runtime
  
  
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
