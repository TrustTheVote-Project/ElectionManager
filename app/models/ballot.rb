class Ballot < ActiveRecord::Base
  #named_scope :create_by_election_and_precinct_split, lambda{ |election, precinct_split| Ballot.create!(:election => election, :precinct_split => precinct_split)}
  
  belongs_to :election
  belongs_to :precinct_split

  validates_presence_of :election, :precinct_split

  def districts
   #  puts "TGD #{self.class.name}#districts: election districts = #{election.district_set.districts.map(&:display_name)}"
#     puts "TGD #{self.class.name}#districts: election districts = #{election.districts.map(&:display_name)}"
#     puts "TGD #{self.class.name}#districts: precinct_split districts = #{precinct_split.districts.map(&:display_name)}"
    election.district_set.districts & precinct_split.districts
  end
  def contests
    districts.map(&:contests).flatten.uniq
  end
end
