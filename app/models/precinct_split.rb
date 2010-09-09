class PrecinctSplit < ActiveRecord::Base
  belongs_to :precinct
  belongs_to :district_set # A precinct list has a single district set

  # intersection of this precinct split's districts and an election's districts
  def ballot_districts(election)
    district_set.districts & election.district_set.jur_districts
  end
  
  # Nice to_s
  def to_s
    s = "S: #{display_name}\n"
    district_set.districts.each do |dist|
      s += "  * d: #{dist.display_name}\n"
    end
    return s
  end
end
