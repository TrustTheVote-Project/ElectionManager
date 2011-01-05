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


class ElectionTest < ActiveSupport::TestCase
  context "using \'setup_test_election\'" do
    setup do
      setup_test_election
    end
    
    should "generate a valid election" do
      assert_valid @election
    end
    
    should "generate election with the expected contests" do
      assert_equal 1, @election.contests.count
      assert_equal "Contest 1", @election.contests[0].display_name
    end
    
    should "generate @split1 with two districts" do
      split_districts = @split1.district_set.districts
      assert_equal 2, split_districts.count
      assert_equal "District 1", split_districts[0].display_name
      assert_equal "District 2", split_districts[1].display_name
    end
    
    should "have the correct relationship between election and precinct splits" do
      splits = PrecinctSplit.precinct_jurisdiction_id_is(@election.district_set_id)
      assert_equal 2, splits.length
      assert_equal "Precinct Split 1", splits[0].display_name
      assert_equal "Precinct Split 2", splits[1].display_name
    end
    
    should "have the correct relationship begween election and precincts" do
      splits = PrecinctSplit.precinct_jurisdiction_id_is(@election.district_set_id)
      assert_equal splits[0].precinct, splits[1].precinct
      assert_equal "Precinct 1", splits[0].precinct.display_name
    end
    
    should "have the correct contests and questions on the ballot for a certain precinct split" do
      split = PrecinctSplit.precinct_jurisdiction_id_is(@election.district_set_id)[0]
      assert_equal 1, split.ballot_contests(@election).count
      assert_equal "Contest 1", split.ballot_contests(@election)[0].display_name
      assert_equal 2, split.ballot_questions(@election).count
      assert_equal "Question 1", split.ballot_questions(@election)[0].display_name
    end
    
    should "generate a correct ballot listing" do
      assert_equal 3,@election.generate_ballot_proofing.lines.count
    end
  end
end
