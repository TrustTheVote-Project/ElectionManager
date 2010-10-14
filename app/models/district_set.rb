  class DistrictSet < ActiveRecord::Base
  has_and_belongs_to_many :districts
  has_many :jur_districts, :class_name => "District", :foreign_key => :jurisdiction_id
  has_many :elections
  has_many :audits
  has_many :precincts, :foreign_key => :jurisdiction_id
  has_many :precinct_splits, :through => :precincts
  
  has_many :jurisdiction_memberships, :class_name => "JurisdictionMembership"
  has_many :users, :through => :jurisdiction_memberships
  
  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique jurisdiction ident attempted: {{value}}."
  
  def has_logo?
    !logo_ident.nil?
  end

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "juris-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
end
