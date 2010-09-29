require 'test_helper'

class ElectionPrecinctSplitTest < ActiveSupport::TestCase
  
  context "Election and precinct split in different jurisdictions" do
    setup do
      # create 9 districts
      9.times do |i|
        District.make(:display_name => "district_#{i}")
      end
      
      # create a district set has the first 6 districts created above
      split_jurisdiction = DistrictSet.make(:display_name => "split_jurisdiction")
      (0..5).to_a.each do |i|        
        split_jurisdiction.districts << District.find_by_display_name("district_#{i}")
      end
      
      # create a precinct with this district set
      @precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => split_jurisdiction)
      # create a precinct_split with this district set and precinct
      @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1",:precinct => @precinct, :district_set => split_jurisdiction)

      # create an election district set that has districts 3 thru 8
      # created above
      election_jurisdiction =  DistrictSet.make(:display_name => "election_jurisdiction")
      (3..8).to_a.each do |i|
        election_jurisdiction.districts << District.find_by_display_name("district_#{i}")
      end
      # create an election.
      @election = Election.make(:display_name => "Election 1", :district_set => election_jurisdiction)
    end
    
    should "have 6 districts for the election " do
      assert_equal 6, @election.district_set.districts.size
    end
    
    should "have 1 district for the precinct split" do
      assert_equal 6, @precinct_split.district_set.districts.size
    end

    should "have 3 districts in common, districts in election and the precinct_split" do
      common_districts = @election.district_set.districts & @precinct_split.district_set.districts
      assert_equal 3, common_districts.size
      assert_equal 3, common_districts.size
      d3 = District.find_by_display_name("district_3")
      d4 = District.find_by_display_name("district_4")
      d5 = District.find_by_display_name("district_5")
      assert_same_elements common_districts,[d3,d4,d5] 
    end


    should "have no precincts in the election" do
      # because the election and the precinct are in diferrent
      # juridisctions.
      assert_equal 0, @election.district_set.precincts.size
    end
    
    should "have no precinct_splits in the election " do
      # because the election and the precinct split are in diferrent
      # juridisctions.
      assert_equal 0, @election.precinct_splits.size
    end
    
    should "have no precinct splits in the election" do
      # because the election and the precinct split are in diferrent
      # juridisctions.
      assert_equal 0, @election.district_set.precinct_splits.size
    end
  end
  
  context "Election and precinct split in the same jurisdictions" do
    setup do
      common_jurisdiction = DistrictSet.make(:display_name => "common_jurisdiction")
      # create 9 districts
      9.times do |i|
        common_jurisdiction.districts << District.make(:display_name => "district_#{i}")
      end

      # TODO: what happens when the precinct and precinct_split have
      # different jurisdictions?
      @precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => common_jurisdiction)
      @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1",:precinct => @precinct, :district_set => common_jurisdiction)

      # create an election.
      @election = Election.make(:display_name => "Election 1", :district_set => common_jurisdiction)
    end
    
    should "have all 9 districts in common, districts in election and the precinct_split" do
      common_districts = @election.district_set.districts & @precinct_split.district_set.districts
      assert_equal 9, common_districts.size
      districts = []
      
      9.times do |i|
        districts << District.find_by_display_name("district_#{i}")
      end
      assert_same_elements districts, common_districts 
    end
    
    should "have one precincts in the election" do
      assert_equal 1, @election.district_set.precincts.size
    end
    
    should "have one precinct_splits in the election " do
      assert_equal 1, @election.precinct_splits.size
    end
    
    should "have one precinct splits in the election" do
      assert_equal 1, @election.district_set.precinct_splits.size
    end

  end
end
