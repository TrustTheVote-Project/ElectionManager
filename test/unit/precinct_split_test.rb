require 'test_helper'

class PrecinctSplitTest < ActiveSupport::TestCase
  
  context 'Precinct Split' do
    setup do
      @dist_set = DistrictSet.make(:display_name => "some districts")
    end
    
    
    should "accept an attached Precinct" do
      assert_equal 0, PrecinctSplit.count
      prec_split = PrecinctSplit.make(:district_set => @dist_set)
      
      prec = Precinct.make
      prec.precinct_splits << prec_split
      
      assert_equal 1, prec.precinct_splits.length
      assert_equal 1, PrecinctSplit.count
    end
    
    context "iterators" do
      setup do
        setup_test_election
      end
    
      should "correctly return ballot contests" do
        # ap @split1.ballot_contests(@election)
        # puts 1
      end 
    end    
  end
end
