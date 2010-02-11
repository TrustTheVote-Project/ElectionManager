# == Schema Information
# Schema version: 20100210222409
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
  
  validates_format_of :ident, 
      :with => /^prec-\d+/,
      :message => "invalid format of prec.ident", 
      :if => Proc.new { |p| !p.new_record?}

  # Make sure that ident is not nil.
  def after_save
    if self.ident.nil?
      self.ident = "prec-#{Time.now.to_i}"
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
