class District < ActiveRecord::Base
  has_and_belongs_to_many :district_sets

  has_many :contests, :order => :display_name
  has_many :questions, :order => :display_name
  belongs_to :district_type
  belongs_to :jurisdiction, :foreign_key => :jurisdiction_id, :class_name => "DistrictSet"  
  
  attr_accessible :district_type, :display_name, :district_type_id, :ident, :position
  
  attr_accessor :importId, :importPrecincts # for xml import
  validates_presence_of :display_name
  validates_presence_of :jurisdiction
  
  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique district ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "dist-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end
  
  # we assume election has preloaded the contents/questions
  def contestsForElection(election)
    return election.contests.select { |c| c.district_id == self.id }
  end
  
  def questionsForElection(election)
    return election.questions.select { |q| q.requesting_district.id == self.id }
  end
  
  def to_s
    "Dist: #{display_name}"
  end
  
end
