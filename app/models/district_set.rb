class DistrictSet < ActiveRecord::Base
  has_and_belongs_to_many :districts
  has_many :jur_districts, :class_name => "District", :foreign_key => :jurisdiction_id
  has_many :elections
  has_many :audits
  has_many :precincts, :foreign_key => :jurisdiction_id
  has_attached_file :icon, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  has_many :jurisdiction_memberships, :class_name => "JurisdictionMembership"
  has_many :users, :through => :jurisdiction_memberships
  
  # returns all precincts in this district set
#  def precincts
#    precinct_ids = connection.select_values( <<-eos
#      SELECT DISTINCT districts_precincts.precinct_id
#      FROM	districts_precincts, district_sets_districts
#      WHERE	district_sets_districts.district_set_id = #{self.id}
#      AND	district_sets_districts.district_id = districts_precincts.district_id
#    eos
#    )
#    Precinct.find(precinct_ids)
#  end
  
  # validates_presence_of :ident
  # validates_uniqueness_of :ident, :message => "Non-unique jurisdiction ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "juris-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
end
