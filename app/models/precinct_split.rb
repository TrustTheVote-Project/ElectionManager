class PrecinctSplit < ActiveRecord::Base
  belongs_to :precinct
  belongs_to :district_set # A precinct list has a single district set
  has_many :districts, :through => :district_set
end
