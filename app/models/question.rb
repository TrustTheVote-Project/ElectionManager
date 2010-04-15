# == Schema Information
# Schema version: 20100215144641
#
# Table name: questions
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  question     :text
#  district_id  :integer
#  election_id  :integer
#  created_at   :datetime
#  updated_at   :datetime
#

class Question < ActiveRecord::Base

  belongs_to  :requesting_district, :class_name => 'District'
  belongs_to :election

  attr_accessible :display_name, :question, :district_id , :election_id
  
  validates_presence_of :display_name, :question, :requesting_district_id, :election_id
  validates_numericality_of :requesting_district_id, :election_id

  def to_s
    "QUESTION: #{self.display_name}"
  end
end
