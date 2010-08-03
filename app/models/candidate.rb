# == Schema Information
# Schema version: 20100802153118
#
# Table name: candidates
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  party_id     :integer
#  contest_id   :integer
#  created_at   :datetime
#  updated_at   :datetime
#  ident        :string(255)
#  order        :integer         default(0)
#

class Candidate < ActiveRecord::Base
  belongs_to :contest
  belongs_to :party
  
  attr_accessible :order, :ident
  
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
