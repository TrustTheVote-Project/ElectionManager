require 'test_helper'

class PrecinctSplitTest < ActiveSupport::TestCase
  
  context 'Precinct Split' do
    should "accept an attached DistrictSet" do
      dist_set = DistrictSet.make(:display_name => "some districts")
      prec_split = PrecinctSplit.make(:display_name => "PSplit", :district_set => dist_set)
      assert_equal "some districts", prec_split.district_set.display_name
    end
    
    should "accept an attached Precinct" do
      dist_set = DistrictSet.make
      prec_split = PrecinctSplit.make(:district_set => dist_set)
      prec = Precinct.make
      prec.precinct_splits << prec_split
      assert_equal 1, prec.precinct_splits.length
    end
    
    should "allow enumeration of all districts of a precinct" do
      dist_set = DistrictSet.make
      10.times { dist_set.districts << District.make }
      prec_split = PrecinctSplit.make(:district_set => dist_set)
      prec = Precinct.make
      prec.precinct_splits << prec_split
      assert_equal 10, prec.districts.length
    end
  end
end
