class Contest < ActiveRecord::Base
  # requesting district
  belongs_to  :district
  belongs_to :election
  belongs_to :voting_method
  has_many :candidates, :dependent => :destroy, :order => :display_name
  attr_accessible :display_name, :open_seat_count, :voting_method_id , :candidates_attributes, :election_id, :district, :position, :ident
  accepts_nested_attributes_for :candidates, :allow_destroy => true, :reject_if => proc { |attributes| attributes['display_name'].blank? }
  
  validates_presence_of :display_name, :open_seat_count, :voting_method_id, :district
  validates_numericality_of :open_seat_count
  validates_associated :district, :election
  
  def validate
    osc = open_seat_count.to_i
    errors.add(:open_seat_count, "must be more than 0") if osc < 1
    errors.add(:open_seat_count, "must be less than 10") if osc > 10
    errors.add(:voting_method_id, "is invalid") if !VotingMethod.exists?(voting_method_id)
  end
  
  def after_initialize
    write_attribute(:open_seat_count, 1) if !open_seat_count
    write_attribute(:voting_method_id, 0) if !voting_method_id
  end
  
  def to_s
    "CONTEST #{self.display_name}"
  end

  
  def self.contests_for_precinct_election(p, e)
    d = p.districts_for_election(e)
    e.contests.map do |c|
      c if d.include?(c.district)      
    end.flatten.compact
  end
  
  #validates_presence_of :ident
  #validates_uniqueness_of :ident, :message => "Non-unique contest ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
=begin  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "cont-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
=end
end
