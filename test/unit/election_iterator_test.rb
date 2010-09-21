require 'test_helper'

class ElectionTest < ActiveSupport::TestCase
  def self.should_have_n_ballots n
    should "have #{n} ballots" do
      ballot_count = 0
      @e1.each_ballot @p1 do
        |split, cont_list, quest_list|
        ballot_count += 1
      end
      assert_equal n, ballot_count
    end
  end
  
  context "Election" do
    setup do
      @e1 = Election.make
      @p1 = setup_precinct "Precinct A", 3
      @d1 = @p1.precinct_splits[0].district_set.districts[0]
      @d2 = @p1.precinct_splits[2].district_set.districts[1]
    end
    
    should_have_n_ballots 0
    
    context "after adding one contest" do
      setup do
        @c = Contest.make
        @c.district = @d1
        @e1.contests << @c
      end
      
      should_have_n_ballots 1
      
      context "and adding one question" do
        setup do
          @q = Question.make
          @q.requesting_district = @d2
          @q.save
          @e1.questions << @q
        end
        
        should_have_n_ballots 2
        
        should "correctly count using the enumerator" do
          all_ballots = @e1.all_ballots @p1
          assert_equal 2, all_ballots.length
        end
      end
    end
  end
  
  context "Election" do
    setup do 
      setup_test_election
     end
     
    should "have one contest district" do
      assert_equal 1, @election.contests.length
      assert_equal "Contest 1",  @election.contests.first.display_name
      assert_equal "District 1", @election.contests.first.district.display_name
    end
    
    should "have two districts in this election's district set" do
      assert_equal 2, @election.district_set.districts.length
      assert_equal "District 1",  @election.district_set.districts.first.display_name
      assert_equal "District 2",  @election.district_set.districts.last.display_name
    end
    
    should "have 2 precinct splits" do
      assert_equal 2, @election.precinct_splits.length
      assert_contains @election.precinct_splits.map(&:display_name),  @split1.display_name
      assert_contains @election.precinct_splits.map(&:display_name),  @split2.display_name 
    end
    
  end
end
