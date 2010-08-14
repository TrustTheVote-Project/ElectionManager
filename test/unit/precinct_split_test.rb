require 'test_helper'

class PrecinctSplitTest < ActiveSupport::TestCase
  
  context 'Precinct Split' do
    setup do
      @dist_set = DistrictSet.make(:display_name => "some districts")

    end
    #     should "accept an attached DistrictSet" do

    #       prec_split = PrecinctSplit.make(:display_name => "PSplit", :district_set => @dist_set)
    #       assert_equal "some districts", prec_split.district_sets.first.display_name
    #     end
    
    should "accept an attached Precinct" do
      assert_equal 0, PrecinctSplit.count
      prec_split = PrecinctSplit.make(:district_set => @dist_set)
      
      prec = Precinct.make
      prec.precinct_splits << prec_split

      assert_equal 1, prec.precinct_splits.length
      assert_equal 1, PrecinctSplit.count
    end

    should "add a district_set to a precinct" do
      prec_split = PrecinctSplit.make(:district_set => @dist_set)
      prec = Precinct.make
      prec.precinct_splits << prec_split
      assert_equal 1, prec.district_sets.size
      ds = prec.district_sets.first
      assert_equal "some districts", ds.display_name
      assert_equal ds, @dist_set

    end

    should "be able to get a precincts districts" do                                                                                   
      10.times { @dist_set.districts << District.make }                                                                                
      prec_split = PrecinctSplit.make(:district_set => @dist_set)                                                                      
      prec = Precinct.make                                                                                                             
      prec.precinct_splits << prec_split                                                                                               
      ds = prec.district_sets.first                                                                                                    
      assert_equal 10, prec.district_sets.first.districts.size                                                                         
    end 
  end
end
