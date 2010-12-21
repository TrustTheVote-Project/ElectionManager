# OSDV Election Manager - Unit Test for Ballot ...more of them
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

require 'test_helper'

class BallotMoreTest < ActiveSupport::TestCase
  context "small jurisdiction" do
    setup do
      struct = ["Jur", [["Prec1", [["Split1", ["Dist1", "Dist2"]]]],
                        ["Prec2", [["Split2", ["Dist3", "Dist4", "Dist5"]]]]]]
      result = setup_juris_structured(struct)

      @juris =        result[0]
      @dist1 =        result[1][0][1][0][1][0]
      @dist2 =        result[1][0][1][0][1][1]      
      @dist3 =        result[1][1][1][0][1][0]
      @dist4 =        result[1][1][1][0][1][1]
      @dist5 =        result[1][1][1][0][1][2]
      @prec1split1 =  result[1][0][1][0][0]
    end
    
    context "ballot" do
      setup do
        @el = Election.create(:display_name => "Test")
        @ball1 = Ballot.create(:election => @el, :precinct_split => @prec1split1)
      end
      
      should "be blank if there are no contests" do
        assert_equal Ballot, @ball1.class
        assert @ball1.blank?
      end
      
      should "be non-blank with contest added to districts in precsplit1" do
        c1 = Contest.create(:display_name => "C1", :election => @el, :district => @dist1, :open_seat_count => 1, :voting_method => VotingMethod::WINNER_TAKE_ALL)
        assert c1.valid?
        assert !@ball1.blank?
        assert_equal c1, @ball1.contests[0]
      end
      
      should "be blank with contests added to districts in precsplit2" do
        c1 = Contest.create(:display_name => "C1", :election => @el, :district => @dist5, :open_seat_count => 1, :voting_method => VotingMethod::WINNER_TAKE_ALL)
        assert c1.valid?
        assert @ball1.blank?

      end
    end
  end

#
# Now actually import a sample jurisdiction, election and contest set for testing.
#
#
# helper method to string together the steps for doing an import when we know there will be no audit errors.
#
  def import_helper(filename, contenttype)
      yaml_hash = YAML.load(File.new("#{RAILS_ROOT}/test/unit/data/ballot_more_test/#{filename}.yml"))
      audit = Audit.new(:content_type => contenttype, :election_data_hash => yaml_hash, :district_set => @juris)
      audit.audit 
      import = TTV::ImportEDH.new(contenttype, audit.election_data_hash)
      import.import @juris
  end
  context "using test yml files" do
    setup do
      @juris = DistrictSet.create!(:display_name => "Jurisdiction Test")
# Import Precincts, Districts, etc.
      import_helper("ballot_more_juris", "jurisdiction_info")
# Import Contests Questions, etc. from ballot_more_elect1.yml
      import_helper("ballot_more_elect1", "election_info")
# Import Contests Questions, etc. from ballot_more_elect2.yml
      import_helper("ballot_more_elect2", "election_info")
    end
    
    should "result in reasonable results" do
      assert 2, Election.all.count
    end
    
    should "create a valid precinct split" do
      elect = Election.find_by_display_name("Election ONE")
      split = PrecinctSplit.find_by_display_name("split-1-SMD 02-ANC 6C")
      assert_equal 4, split.districts.length
# Grab contests for Districts that are in that PrecinctSplit
      contests = Contest.district_id_is(split.districts.map(&:id))
      assert 2, contests.length
    end
    
    should "have a ballot with a single contest" do
      split = PrecinctSplit.find_by_display_name("split-1-SMD 02-ANC 6C")
      elect = Election.find_by_display_name("Election ONE")
      ballot = Ballot.new(:election => elect, :precinct_split => split)
      if ballot.contests.length != 1
          ap ballot
          ap split
          ap elect
          ap Contest.district_id_is(split.districts.map(&:id))
        end
      assert_equal 1, ballot.contests.length
    end

    should "all PrecinctSplits should have blank Ballots" do
      elect = Election.find_by_display_name("My Election")
      splitlist =["split-1-SMD 01-ANC 6C","split-1-SMD 03-ANC 6C","split-1-SMD 09-ANC 6C","split-2-SMD 01-ANC 2A","split-2-SMD 05-ANC 2A","split-2-SMD 06-ANC 2A"]
      splitlist.each do
        |nm| 
        split = PrecinctSplit.find_by_display_name(nm)
        ballot = Ballot.create(:election => elect, :precinct_split => split)
        if ballot.contests.length != 0
          ap ballot
          ap split
          ap Contest.district_id_is(split.districts.map(&:id))
        end
        assert_equal 0, ballot.contests.length
      end
    end  
  end
end



