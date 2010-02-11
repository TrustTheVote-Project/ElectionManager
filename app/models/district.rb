# == Schema Information
# Schema version: 20100210222409
#
# Table name: districts
#
#  id               :integer         not null, primary key
#  district_type_id :integer
#  display_name     :string(255)
#  created_at       :datetime
#  updated_at       :datetime
#

class District < ActiveRecord::Base
  has_and_belongs_to_many :district_sets
  has_and_belongs_to_many :precincts

  has_many :contests, :order => :display_name
  has_many :questions, :order => :display_name

  belongs_to :district_type
  
  attr_accessible :district_type, :display_name, :district_type_id
  
  attr_accessor :importId, :importPrecincts # for xml import
  
  validates_presence_of :display_name
  
  # we assume election has preloaded the contents/questions
  def contestsForElection(election)
    return election.contests.select { |c| c.district_id == self.id }
#    Contest.find_all_by_election_id_and_district_id(election.id, self.id)
  end
  
  def questionsForElection(election)
    return election.questions.select { |q| q.district_id == self.id }
#    Question.find_all_by_election_id_and_district_id(election.id, self.id)
  end
  
end
