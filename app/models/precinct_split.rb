class PrecinctSplit < ActiveRecord::Base
  belongs_to :precinct
  belongs_to :district_set # A precinct list has a single district set

  # intersection of this precinct split's districts and an election's districts
  def ballot_districts(election)
    district_set.districts & election.district_set.jur_districts
  end

# Return all the contests corresponding to this precinct split, in this election. The logic goes like this:
# 
  def ballot_contests(election)
    election.contests.reduce([]) { |memo, contest| district_set.districts.include?(contest.district) ? memo | [contest] : memo}
  end
  
  def ballot_questions(election)
    election.questions.reduce([]) { |memo, question| district_set.districts.include?(question.requesting_district) ? memo | [question] : memo}
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
