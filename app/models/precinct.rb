class Precinct < ActiveRecord::Base
  
  has_many :precinct_splits
  belongs_to :jurisdiction, :foreign_key => :jurisdiction_id, :class_name => "DistrictSet" 

  attr_accessible :jurisdiction, :display_name, :ident

  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique Precinct ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "prec-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end

# TODO rename this method to just 'districts'
  def collect_districts
    precinct_splits.reduce([]) { |coll, ps| coll | ps.district_set.districts}
  end

# Is this precinct a split precinct? A "split precinct" in the vernacular corresponds
# to a Precinct with one PrecinctSplit in our schema.
  def split?
    precinct_splits.size != 1
  end

  def districts_for_election(election)
    p = collect_districts
    e = election.collect_districts
    p & e
  end
  
# Nice to_s
  def to_s
    s = "P: #{display_name}\n"
    precinct_splits.each do |ps|
      s += "  * s: #{ps.to_s}\n"
    end
    return s
  end
end
