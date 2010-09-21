
class Candidate < ActiveRecord::Base
  belongs_to :contest
  belongs_to :party
  
  attr_accessible :position, :ident, :display_name
  
  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique candidate ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "cand-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
  

  attr_accessible :display_name, :party_id, :contest_id
  validates_presence_of :display_name
  
  # default values, should not be all republican/democrat
  def after_initialize
  #  write_attribute(:party_id, rand(3)) if !party_id
  end
  
  def validate
   # errors.add(:display_name , "must start with an A") unless display_name.start_with? "A"
  end
  

end
