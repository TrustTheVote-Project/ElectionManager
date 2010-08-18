# == Schema Information
# Schema version: 20100813053101
#
# Table name: questions
#
#  id                     :integer         not null, primary key
#  display_name           :string(255)
#  question               :text
#  election_id            :integer
#  created_at             :datetime
#  updated_at             :datetime
#  requesting_district_id :integer
#  ident                  :string(255)
#

class Question < ActiveRecord::Base
  
  belongs_to :requesting_district, :class_name => 'District'
  belongs_to :election

  attr_accessible :display_name, :question, :district_id , :election_id
  
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
  
  #validates_presence_of :ident
  #validates_uniqueness_of :ident, :message => "Non-unique question ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
=begin  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "qstn-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
=end
end
