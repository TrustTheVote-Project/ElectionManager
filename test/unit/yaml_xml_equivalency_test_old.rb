# OSDV Election Manager - Unit Test
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require File.dirname(__FILE__) + '/../test_helper'


class YAMLXMLEquivalencyTest < ActiveSupport::TestCase
  
  #
  # Contains assertions that certify the election objects election1 and 
  # election2 are functionally equivalent
  #  
  def assert_election_equal election1, election2
    assert_equal election1.display_name, election2.display_name
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
      e2_contests = election2.contests.find_all_by_display_name(e1_contest.display_name)
      
      assert !e2_contests.empty?, "Contest #{e1_contest.display_name} has no counterpart"

      e2_contest = nil
      
      e2_contests.each {|check_contest|
        if e1_contest.district.display_name == check_contest.district.display_name and candidates_equal?(e1_contest, check_contest)
          e2_contest = check_contest
        end 
      }
      
      assert e2_contest, "Contest #{e1_contest.display_name} in district #{e1_contest.district.display_name} has no counterpart."

    }
  end

  # Checks whether two contests have the same candidates
  def candidates_equal?(e1_contest, e2_contest)
    equal = true
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
    return equal
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
  
  def xml_to_yaml xml_source
    @file = File.new(xml_source)

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
    
    assert_election_equal @xml_election, @yaml_election
  end
  
  # Import XML as @xml_election, exports as YML, imports YML as @yml_election
  context "An XML-imported election and its YAML export / import" do
    setup do
      xml_to_yaml "test/elections/contests_mix.xml"       
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
  
  def yaml_to_xml yaml_source
    @file = File.new(yaml_source)

    # Import YML election
    @yaml_import = TTV::YAMLImport.new(@file)
    @yaml_import.import
    @yaml_election = @yaml_import.election
    
    # Export XML election
    @xml_export = TTV::ImportExport.export(@yaml_election)
    @xml_election = TTV::ImportExport.import(@xml_export)
    
    assert_election_equal @yaml_election, @xml_election
  end
  
  # Import YML as @yml_election, exports as XML, imports XML as @xml_election
  context "A YML-imported election and its XML export / import" do
    should "Convert a yaml election back and forth to XML" do
      yaml_to_xml "test/elections/TX_ballot_config.yml" 
    end
    
    if false
      should "have valid yaml and xml elections" do
        assert_valid @yaml_election
        assert_valid @xml_election
      end
      
      should "be equal elections" do
        assert @yaml_election == @xml_election
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
    end # if false
  end
    
  context "In test/elections" do
    setup do
      @xml_election = @yaml_election = nil
    end
    
    def self.should_xml_import path
      should "import XML file '#{path}'" do
        xml_to_yaml path
      end
    end
  
    def self.should_yaml_import path
      should "import YAML file '#{path}'" do
        yaml_to_xml path
      end
    end

    should_xml_import "db/samples/GeneralElection2010.xml"
    should_yaml_import "test/elections/generated.yml"
    should_yaml_import "test/elections/TX_ballot_config.yml"
    should_yaml_import "test/elections/nh/Acworth.yml"

    if false
      # Iterate through directories, testing import and export of .yml and .xml elections
      dirs = ["test/elections","db/samples"]
      excludes = [".nothing"]
      for dir in dirs
        Find.find(dir) do |path|
          if FileTest.directory?(path)
            if excludes.include?(File.basename(path))
              Find.prune # Don't look down this dir
            else
              next
            end
          else
            should_yaml_import path if File.extname(path) == ".yml"
            should_xml_import path if File.extname(path) == ".xml"
          end
        end
      end
    end #if false
  end
end