class Precinct < ActiveRecord::Base
  
  has_many :precinct_splits
  belongs_to :jurisdiction, :foreign_key => :jurisdiction_id, :class_name => "DistrictSet"  
  
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
  
  def collect_districts
    precinct_splits.reduce([]) { |coll, ps| coll |= ps.district_set.districts}
  end

#  def districts_for_election(election)
#    districts & election.district_set.districts
#  end

# Is this precinct a split precinct?
  def split?
    precinct_splits.size != 1
  end

# For now we are assuming one PrecinctSplit per Precinct.
  def districts_for_election(election)
    prec_districts = collect_districts
    district_list.districts & election.contests
  end
  
# Nice to_s
  def to_s
    s = "P: #{display_name}\n"
    precinct_splits.each do |ps|
      s += "  * s: #{ps.to_s}\n"
    end
    return s
  end
  
# TODO: fix for split precincts
  # Return a list of DistrictSets that this Precinct belongs to. 
  # In the real world, this should always be a list of length 1, even though the data model permits more
#  def district_sets
#    districts.reduce([]) { |res, dist| res.include?(dist.district_sets[0]) ? res : res << dist.district_sets[0] }
#  end
end
