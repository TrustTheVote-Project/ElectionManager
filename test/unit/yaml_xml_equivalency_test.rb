require 'test_helper'
require 'pp'
require 'ttv/yaml_import'
require 'ttv/yaml_export'
require 'ttv/import_export' # XML import/export
require 'shoulda'
require 'yaml'


class YAMLXMLEquivalencyTest < ActiveSupport::TestCase
  
  #
  # Contains assertions that certify the election objects election1 and 
  # election2 are functionally equivalent
  #  
  def assert_election_equal election1, election2
    assert_contests_equal election1, election2
    assert_districts_equal election1, election2
    assert_questions_equal election1, election2
  end
  
  #
  # Contains assertions that certify the election objects election1 and 
  # election2 contain equivalent contests, district associations, candidates, parties
  #
  def assert_contests_equal election1, election2
    election1.contests.each {|e1_contest|
      e2_contest = election2.contests.find_by_display_name(e1_contest.display_name)
      assert e2_contest

      assert_equal e1_contest.district.display_name, e2_contest.district.display_name

      # contain the same candidates associated with the same party
      e1_contest.candidates.each {|e1_candidate|
        # handle multiple candidates with the same name, different parties
        e2_candidates = e2_contest.candidates.find_all_by_display_name(e1_candidate.display_name)
        
        assert !e2_candidates.empty?
        
        match = false
        
        e2_candidates.each {|e2_candidate|          
          if e2_candidate.party.display_name == e1_candidate.party.display_name
            match = true
          end
        }
        
        assert match, "Candidate parties do not match."
      }
    }
  end

  #
  # Contains assertions that certify the election objects election1 and 
  # election2 contain equivalent precincts and associated districts
  #
  def assert_districts_equal election1, election2
    election1.districts.each {|e1_district|
      e2_district = election2.districts.find_by_display_name(e1_district.display_name)
      assert e2_district
      
      # is the same district type
      assert_equal e1_district.district_type, e2_district.district_type
      
      # contain the same precincts
      e1_district.precincts.each {|e1_precinct|
        e2_precinct = e2_district.precincts.find_by_display_name(e1_precinct.display_name)
        assert e2_precinct
      }
    }
  end

  #
  # Contains assertions that certify the election objects election1 and 
  # election2 contain equivalent questions and associated districts
  #  
  def assert_questions_equal election1, election2
        election1.questions.each {|e1_question|
        e2_question = election2.questions.find_by_display_name(e1_question.display_name)
        assert e2_question
        
        assert_equal e1_question.question, e2_question.question
        
        assert_equal e1_question.district.display_name, e2_question.district.display_name
      }
  end
  
  # Import XML as @xml_election, exports as YML, imports YML as @yml_election
  context "An XML-imported election and its YAML export / import" do
    setup do
      @file = File.new("test/elections/contests_mix.xml")

      # Import XML election
      @xml_election = TTV::ImportExport.import(@file)
      assert_not_nil @xml_election
      
      # Export YML
      @yaml_export = TTV::YAMLExport.new(@xml_election)
      @yaml_string = YAML.dump(@yaml_export.do_export)
      # PREDICTION: have to add ballot type support to yaml_export? 

      # Import YML
      @yaml_import = TTV::YAMLImport.new(@yaml_string)
      @yaml_import.import
      @yaml_election = @yaml_import.election
      
    end
    
    should "contain the same election name" do
      assert_equal @xml_election.display_name, @yaml_election.display_name
    end
    
    should "contain the same contests, candidates, parties" do
      assert_contests_equal @xml_election, @yaml_election
    end
    
    should "contain the same districts and precincts" do
      assert_districts_equal @xml_election, @yaml_election
    end
    
    should "contain the same questions" do
      assert_questions_equal @xml_election, @yaml_election
    end
    
    should "import should get an election of the right name" do
      assert_equal "contests_mix.xml", @yaml_election.display_name
      assert_valid @yaml_election
    end
  end
  
  # Import YML as @yml_election, exports as XML, imports XML as @xml_election
  context "A YML-imported election and its XML export / import" do
    setup do
      @file = File.new("test/elections/nh/Albany.yml")

      # Import YML election
      @yaml_import = TTV::YAMLImport.new(@file)
      @yaml_import.import
      @yaml_election = @yaml_import.election
      
      # Export XML election
      puts "XML EXPORT"
      @xml_export = TTV::ImportExport.export(@yaml_election) 
      puts "XML IMPORT"
      @xml_import = TTV::ImportExport.import(@xml_export)
      
      @xml_election = @xml_import
    end
  
    should "have valid yaml and xml elections" do
      assert_valid @yaml_election
      assert_valid @xml_election
    end
    
    should "contain the same election name" do
      assert_equal @xml_election.display_name, @yaml_election.display_name
    end
    
    should "contain the same contests, candidates, parties" do
      assert_contests_equal @xml_election, @yaml_election
    end
    
    should "contain the same districts and precincts" do
      assert_districts_equal @xml_election, @yaml_election
    end
    
    should "contain the same questions" do
      assert_questions_equal @xml_election, @yaml_election
    end
  end
end