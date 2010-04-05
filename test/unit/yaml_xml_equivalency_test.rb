require 'test_helper'
require 'pp'
require 'ttv/yaml_import'
require 'ttv/yaml_export'
require 'ttv/import_export' # XML import/export
require 'shoulda'
require 'yaml'


class YAMLXMLEquivalencyTest < ActiveSupport::TestCase
  
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
      
      # YML Import / Export
      #@import_obj = TTV::YAMLImport.new(@file)
      #@import_obj.import
      #@export_obj = TTV::YAMLExport.new(@import_obj)
      #@export_obj.do_export
        
      # XML Import / Export
      #@xml_export_obj = TTV::ImportExport.export(election)
      #@xml_import_obj = TTV::ImportExport.import(xml)
    end
    
    should "contain the same election name" do
      assert_equal @xml_election.display_name, @yaml_election.display_name
    end
    
    should "contain the same contests, candidates, parties" do
      @xml_election.contests.each {|xml_contest|
        yaml_contest = @yaml_election.contests.find_by_display_name(xml_contest.display_name)
        assert yaml_contest
        
        # contain the same candidates associated with the same party
        xml_contest.candidates.each {|xml_candidate|
          yaml_candidate = yaml_contest.candidates.find_by_display_name(xml_candidate.display_name)
          assert yaml_candidate

          # puts "XML xml_candidate: " + xml_candidate.display_name + " party " + xml_candidate.party.display_name
          # puts "YAML yaml_candidate: " + yaml_candidate.display_name + " party " + yaml_candidate.party.display_name
          assert_equal yaml_candidate.party.display_name, xml_candidate.party.display_name
        }
      }
    end
    
    should "contain the same districts and precincts" do
      @xml_election.districts.each {|xml_district|
        yaml_district = @yaml_election.districts.find_by_display_name(xml_district.display_name)
        assert yaml_district
        
        # is the same district type
        assert_equal xml_district.district_type, yaml_district.district_type
        
        # contain the same precincts
        xml_district.precincts.each {|xml_precinct|
          yaml_precinct = yaml_district.precincts.find_by_display_name(xml_precinct.display_name)
          assert yaml_precinct
        }
      }
    end
    
    should "contain the same questions" do
      @xml_election.questions.each {|xml_question|
        yaml_question = @yaml_election.questions.find_by_display_name(xml_question.display_name)
        assert yaml_question
        
        assert_equal xml_question.question, yaml_question.question
        
        assert_equal xml_question.district, yaml_question.district
      }
      
    end
    
    should "import should get an election of the right name" do
      assert_equal "contests_mix.xml", @yaml_election.display_name
      assert_valid @yaml_election
    end
  end
  
  # Import YML as @yml_election, exports as XML, imports XML as @xml_election
  context "A YML-imported election and its XML export / import" do
    setup do
      @file = File.new("test/elections/xml/101.26.yml")

      # Import YML election
      @yaml_import = TTV::YAMLImport.new(@file)
      @yaml_import.import
      @yaml_election = @yaml_import.election
      
      # Export XML election
      @xml_export = TTV::ImportExport.export(@yaml_election) 
      @xml_import = TTV::ImportExport.import(@xml_export)
      
      @xml_election = @xml_import.election
    end
  
    should "have valid yaml and xml elections" do
      assert_valid @yaml_election
      assert_valid @xml_election
    end
  end
end