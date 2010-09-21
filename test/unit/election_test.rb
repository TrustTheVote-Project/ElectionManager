require 'test_helper'

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
