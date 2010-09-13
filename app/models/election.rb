require 'abstract_ballot'
class Election < ActiveRecord::Base
    has_many :contests, :order => :position, :dependent => :destroy
    has_many :questions, :order => :display_name, :dependent => :destroy
    
    attr_accessible :ident, :display_name, :district_set_id, :district_set, :start_date, :district_set
    attr_accessible :default_voting_method_id, :ballot_style_template_id

    validates_presence_of :display_name
    belongs_to :district_set # @TODO Soon this will be :jurisdiction
    
    before_destroy :destroy_translations
    
    def to_s
      s = ""
      attributes.each do |key, value| 
        s += ("#{key}:#{value} ")
      end
      return s
    end

# Return collection of PrecinctSplits associated with this Election. 
# 
    def precinct_splits
#      precincts = Precinct.find_all_by_jurisdiction_id(district_set.id)
#      prec_splits = precincts.map { |prec| prec.precinct_splits }.flatten
      district_set.precincts.map { |prec| prec.precinct_splits }.flatten
    end
    
    def districts
      district_set.jur_districts
    end
    
    def contest_districts
      contests.map(&:district)
    end

    def question_districts
      questions.map(&:requesting_district)
    end
    
# Iterator for generating ballots.
# <tt>param:</tt> A Precinct, then it's all the ballots for this precinct in this election
# <tt>:</tt>A Jurisdiction (DS), then it's all the ballots for this Jurisdiction in this election

    def each_ballot param=nil
      cont_list = contests
      quest_list = questions
      if param.class == Precinct
        prec_splits = param.precinct_splits
      elsif param.class == DistrictSet # TODO will be Jurisdiction in the future)
        precincts = Precinct.find_all_by_jurisdiction_id(param.id)
        prec_splits = precincts.map { |prec| prec.precinct_splits }.flatten
      else 
        raise ArgumentError, "Invalid parameter for Election.each_ballot"
      end
      prec_splits.each do 
        |split|
          result_cont_list = cont_list.reduce([]) do
            |memo, cont| memo |= (split.district_set.districts.member?(cont.district)) ? [cont] : []
          end
          result_quest_list = quest_list.reduce([]) do
            |memo, quest| memo |= (split.district_set.districts.member?(quest.requesting_district)) ? [quest] : []
          end
          yield split, result_cont_list, result_quest_list unless (result_cont_list.length + result_quest_list.length) == 0
      end
    end

# Generate a ballot map, as a Hash. This maps certain characteristics of the ballot to its file name
# TODO: Move this to a BallotUtils or Ballot class which will capture the functionality relating to controling
# ballot generation.
  def generate_ballot_map
    outlist = []
    each_ballot(district_set) do | split, result_cont_list, result_quest_list |

      outlist << {:precinct_split => split.display_name, :file => "#{split.display_name}.pdf"}
    end
    puts "*** #{outlist.inspect}"
    return outlist
  end

# Return an array with the Districts corresponding to this Election's Questions
    def question_districts
      questions.reduce([]) { |memo, q| memo <<  q.requesting_district }      
    end
    
# Return an array with the Districts corresponding to this Election's Contest
    def contest_districts
      contests.reduce([]) { |memo, c| memo << c.district }      
    end
    
# Return an array with the Districts involved in this Election.
    def collect_districts
      q = question_districts
      d = contest_districts
      q | d
    end
    
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

  # TODO: equal_districts? and friends should be moved out of Election, maybe in its owbs class or module?
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
      medium_id = ballot_style_template.medium_id
      title = precinct.display_name.gsub(/ /, "_").camelize + " Ballot.pdf"
      
      if medium_id == 0
        pdfBallot = AbstractBallot.create(election, precinct, ballot_style_template)
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
  
#
# Handy verbose to_s for Elections. Feel free to add useful stuff as needed.
#
  def to_s
    s = "E: #{display_name}, c#: #{contests.count}, q#:#{questions.count}\n"
    contests.each do |c|
      s += "   * c: #{c.display_name} (d: #{c.district.display_name})\n"
    end      
    
    questions.each do |q|
      s += "   * q: #{q.display_name} (d: #{q.requesting_district.display_name})\n"
    end

    return s
  end

end
