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
  
  def districts_for_election(election)
    districts & election.district_set.districts
  end
end
