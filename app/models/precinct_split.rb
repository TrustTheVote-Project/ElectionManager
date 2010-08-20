class PrecinctSplit < ActiveRecord::Base
  belongs_to :precinct
  belongs_to :district_set # A precinct list has a single district set
  
  # Nice to_s
  def to_s
    s = "S: #{display_name}\n"
    district_set.districts.each do |dist|
      s += "  * d: #{dist.display_name}\n"
    end
    return s
  end
end
