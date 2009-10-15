class Question < ActiveRecord::Base

  belongs_to  :district
  belongs_to :election

  attr_accessible :display_name, :question, :district_id , :election_id
  
  validates_presence_of :display_name, :question, :district_id, :election_id
  validates_numericality_of :district_id, :election_id

    
end
