
class Question < ActiveRecord::Base
  
  belongs_to :requesting_district, :class_name => 'District'
  belongs_to :election

# TODO rps Do we really need to include :election_id in the accessible? 
  attr_accessible :ident, :display_name, :position, :question, :requesting_district_id , :election_id
  validates_presence_of :display_name, :question, :requesting_district_id, :election_id
  validates_numericality_of :requesting_district_id, :election_id

  def to_s
    "QUESTION: #{self.display_name}"
  end

  def self.questions_for_precinct_election(p, e)
    d = p.districts_for_election(e)
    e.questions.map do |q|
      q if d.include?(q.requesting_district)      
    end.flatten.compact
  end
  
end
