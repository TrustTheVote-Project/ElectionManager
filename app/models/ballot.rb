class Ballot < ActiveRecord::Base
#   named_scope :find_or_create_by_election, lambda{ |election| election.precinct_splits.each do |split|
#       find_or_create_by_election_id_and_precinct_split_id(:election_id => election.id, :precinct_split_id => split.id)
#     end
#   }
  
  belongs_to :election
  belongs_to :precinct_split
  
  def self.find_or_create_by_election(election)
    ballots = []
    election.precinct_splits.each do |split|
      #result = find_or_create_by_election_id_and_precinct_split_id(:election_id => election.id, :precinct_split_id => split.id)
      #puts "TGD: result = #{result.inspect}"
      #ballots << result
      ballots << find_or_create_by_election_id_and_precinct_split_id(:election_id => election.id, :precinct_split_id => split.id)
    end
    ballots
  end
  
  validates_presence_of :election, :precinct_split

  def districts
    precinct_split.districts
  end
  
  def contests
    Contest.find_all_by_district_id(precinct_split.districts.map(&:id))
  end
  
  def questions
    Question.find_all_by_requesting_district_id(precinct_split.districts.map(&:id))
  end

  def render_pdf
    # TODO: make this a real association
    bst = BallotStyleTemplate.find(election.ballot_style_template_id)
    AbstractBallot.create(election, self.precinct_split, bst)
  end
end
