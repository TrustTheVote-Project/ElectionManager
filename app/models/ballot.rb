class Ballot < ActiveRecord::Base
#   named_scope :find_or_create_by_election, lambda{ |election| election.precinct_splits.each do |split|
#       find_or_create_by_election_id_and_precinct_split_id(:election_id => election.id, :precinct_split_id => split.id)
#     end
#   }
  
  belongs_to :election
  belongs_to :precinct_split
  attr_accessor :filename
  
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
  
  # TODO: refactor clients that use this method
  # to use Ballot instances. Then replace this method with the
  # filename instance method below.
  def self.filename(election, precinct_split,ballot_rule)
    tmp_ballot = new
    tmp_ballot.election = election
    tmp_ballot.precinct_split = precinct_split
    tmp_ballot.filename(&ballot_rule.ballot_filename)
  end
  
  # construct the ballot filename
  def filename(&block)
    # default filename
    @filename = "#{precinct_split.display_name}"
    # set with a block, perhaps in a ballot rule
    if block_given?
      @filename = (block.arity < 1 ? instance_eval(&block) : block.call(self))
    end
    @filename
  end
  
  def contests
    Contest.find_all_by_district_id(precinct_split.districts.map(&:id))
  end
  
  def questions
    Question.find_all_by_requesting_district_id(precinct_split.districts.map(&:id))
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
