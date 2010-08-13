# == Schema Information
# Schema version: 20100813053101
#
# Table name: elections
#
#  id                       :integer         not null, primary key
#  display_name             :string(255)
#  district_set_id          :integer
#  start_date               :datetime
#  created_at               :datetime
#  updated_at               :datetime
#  ballot_style_template_id :integer         default(0)
#  default_voting_method_id :integer         default(0)
#  ident                    :string(255)
#

# == Schema Information
# Schema version: 20100215144641
#
# Table name: elections
#
#  id              :integer         not null, primary key
#  display_name    :string(255)
#  district_set_id :integer
#  start_date      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#
require 'abstract_ballot'
class Election < ActiveRecord::Base
    has_many :contests, :order => :position, :dependent => :destroy
    has_many :questions, :order => :display_name, :dependent => :destroy
    
    validates_presence_of :display_name
    belongs_to :district_set
    
    before_destroy :destroy_translations
    
    def to_s
      s = ""
      attributes.each do |key, value| 
        s += ("#{key}:#{value} ")
      end
      return s
    end
    
    def districts
      @districts = district_set.districts if (!@districts)
      @districts  
    end

    def validate 
       errors.add(:district_set_id , "is invalid") unless DistrictSet.exists?(district_set)
    end
    
    #validates_presence_of :ident
    #validates_uniqueness_of :ident, :message => "Non-unique election ident attempted: {{value}}."
  
    # Make sure that ident is not nil. If it is, create a unique one.
=begin    def before_validation
      if self.blank? || self.ident.blank?
        self.ident = "elec-#{ActiveSupport::SecureRandom.hex}"
        self.save!
      end
    end
=end    
    
    # really used for export. I'd use a different method, if I could force 'render :xml' to call it
    def to_xml( options = {}, &block )
      return TTV::ImportExport.export(self)
    end
    
    TRANSLATION_FOLDER = "#{RAILS_ROOT}/db/translations"
    
    def translation_path(lang)
      "#{TRANSLATION_FOLDER}/election-#{id}.#{lang}.yml"
    end
    
    def destroy_translations
      Dir.foreach TRANSLATION_FOLDER do |f|
        next unless f =~ /election-#{id}.*yml$/
        File.unlink("#{TRANSLATION_FOLDER}/#{f}")
      end
    end
  
    def comp compare
      equal = true
      equal = false if !equal_contests? compare
      equal = false if !equal_districts? compare
      equal = false if !equal_questions? compare
      equal = false if display_name != compare.display_name
      return equal
    end
    
  #
  # Contains assertions that certify the election objects election1 and 
  # election2 contain equivalent contests, district associations, candidates, parties
  #
  def equal_contests? election2
    equal = true
    contests.each {|e1_contest|
      e2_contest = election2.contests.find_by_display_name(e1_contest.display_name)
      equal = false if e2_contest.nil?

      equal = false if e1_contest.district.display_name != e2_contest.district.display_name

      # contain the same candidates associated with the same party
      e1_contest.candidates.each {|e1_candidate|
        # handle multiple candidates with the same name, different parties
        e2_candidates = e2_contest.candidates.find_all_by_display_name(e1_candidate.display_name)
        
        equal = false if e2_candidates.empty?
        
        match = false
        
        e2_candidates.each {|e2_candidate|          
          if e2_candidate.party.display_name == e1_candidate.party.display_name
            match = true
          end
        }
        
        equal = false if match = false
      }
    }
    return equal
  end

  #
  # Contains assertions that certify the election objects election1 and 
  # election2 contain equivalent precincts and associated districts
  #
  def equal_districts? election2
    equal = true
    districts.each {|e1_district|
      e2_district = election2.districts.find_by_display_name(e1_district.display_name)
      equal = false if !e2_district
      
      # is the same district type
      equal = false if e1_district.district_type != e2_district.district_type
      
      # contain the same precincts
      e1_district.precincts.each {|e1_precinct|
        e2_precinct = e2_district.precincts.find_by_display_name(e1_precinct.display_name)
        equal = false if e2_precinct.nil?
      }
    }
    return equal
  end

  #
  # Contains assertions that certify the election objects election1 and 
  # election2 contain equivalent questions and associated districts
  #  
  def equal_questions? election2
    equal = true
    questions.each {|e1_question|
      e2_question = election2.questions.find_by_display_name(e1_question.display_name)
      equal = false if e2_question.nil?
      
      equal = false if e1_question.question != e2_question.question
      
      equal = false if e1_question.district.display_name != e2_question.district.display_name
    }
    return equal
  end
    
    def render_ballot(election, precinct, ballot_style_template)
      style = BallotStyle.find(ballot_style_template.ballot_style).ballot_style_code
      lang = Language.find(ballot_style_template.default_language).code
      instruction_text_url = ballot_style_template.instructions_image.url
      medium_id = ballot_style_template.medium_id
      title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
      
      if medium_id == 0
        pdfBallot = AbstractBallot.create(election, precinct, style, lang, instruction_text_url)
        new_ballot = {:fileName => title, :pdfBallot => pdfBallot, :medium_id => medium_id}
      else
        new_ballot = {:title => title, :medium_id => medium_id}
      end
      return new_ballot
    end
    
    
    
    
    def render_ballots(election, precincts, ballot_style_template)
      style = BallotStyle.find(ballot_style_template.ballot_style).ballot_style_code
      lang = Language.find(ballot_style_template.default_language).code
      instruction_text_url = ballot_style_template.instructions_image.url
      ballot_array = Array.new
      precincts.each do |precinct|
        title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
        pdfBallot = AbstractBallot.create(election, precinct, style, lang, instruction_text_url)
        new_ballot = {:fileName => title, :pdfBallot => pdfBallot}
        ballot_array << new_ballot
      end
      
         
        #new_ballots = {:fileName => title, :pdfBallot => pdfBallot, :medium_id => medium_id}
        
      return ballot_array
    end
    

end
