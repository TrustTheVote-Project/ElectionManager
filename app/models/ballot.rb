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
   #  puts "TGD #{self.class.name}#districts: election districts = #{election.district_set.districts.map(&:display_name)}"
#     puts "TGD #{self.class.name}#districts: election districts = #{election.districts.map(&:display_name)}"
#     puts "TGD #{self.class.name}#districts: precinct_split districts = #{precinct_split.districts.map(&:display_name)}"
    # election.district_set.districts & precinct_split.districts
    precinct_split.districts
  end
  def contests
    districts.map(&:contests).flatten.uniq
  end
end
