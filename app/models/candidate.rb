class Candidate < ActiveRecord::Base
  belongs_to :contest
  belongs_to :party

  attr_accessible :display_name, :party_id, :contest_id

  validates_presence_of :display_name
  
  # default values, should not be all republican/democrat
  def after_initialize
    write_attribute(:party_id, rand(3)) if !party_id
  end
  
  def validate
   # errors.add(:display_name , "must start with an A") unless display_name.start_with? "A"
  end
  

end
