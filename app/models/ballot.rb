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
      ballots << find_or_create_by_election_id_and_precinct_split_id(:election_id => election.id, :precinct_split_id => split.id)
    end
    ballots
  end
  
  validates_presence_of :election, :precinct_split

  def districts
    precinct_split.districts
  end
  
  def contests
#    Contest.find_all_by_district_id(precinct_split.districts.map(&:id))
    Contest.district_id_is(precinct_split.districts.map(&:id)).election_id_is(election_id)
  end
  
  def questions
#    Question.find_all_by_requesting_district_id(precinct_split.districts.map(&:id))
    Question.requesting_district_id_is(precinct_split.districts.map(&:id)).election_id_is(election_id)
  end

  def render_pdf
    # TODO: make the ballot style template belong_to an election
    bst = BallotStyleTemplate.find(election.ballot_style_template_id)
    
    # TODO: refactor this after the above belongs_to is
    # created. BallotStyleTemplate will belong_to an election and the
    # election wont need to be passed to this method.
    ballot_config  = bst.ballot_config(election)
    
    renderer = AbstractBallot::Renderer.new(election, precinct_split, ballot_config, nil)
    # TODO: refactor this crazy magic
    renderer.render
    # calls the Prawn::Document.render method
    renderer.to_s
  end
end
