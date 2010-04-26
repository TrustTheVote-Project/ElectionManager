require 'test_helper'

class ContestsComplexTest < ActiveSupport::TestCase
  
  setup_contest_requesters do
    
    context 'finding contests by requested by districts' do
      should "in the first election of the first precinct" do

        contests = Contest.contests_for_precinct_election(@p1, @e1)
        
        assert_equal 4, contests.size
        4.times do |i|
          assert_contains contests, Contest.find_by_display_name("Contest #{i}")
        end

        (4..7).each do |i|
          assert_does_not_contain contests, Contest.find_by_display_name("Contest #{i}")
        end
      end
      
    end #end context
    
  end # end setup_contest_requesters
  
  
end
