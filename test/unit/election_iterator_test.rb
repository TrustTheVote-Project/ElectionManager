require 'test_helper'

class ElectionTest < ActiveSupport::TestCase
  
  def self.should_have_n_ballots n
    should "have #{n} ballots" do
      ballot_count = 0
      @e1.each_ballot @p1 do
        |cont_list, quest_list|
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
      
      should_have_n_ballots 2
    
      context "and adding one question" do
        setup do
          @q = Question.make
          @q.requesting_district = @d2
          @q.save
          @e1.questions << @q
        end
        
        should_have_n_ballots 1
      end
    end
  end
end
