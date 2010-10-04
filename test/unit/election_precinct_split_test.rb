require 'test_helper'

class ElectionPrecinctSplitTest < ActiveSupport::TestCase
  context "Jurisdiction and Districts" do
    
    setup do
      # Create the DistrictSet which stands in for the Jurisdiction
      @jurisdiction_ds =  DistrictSet.make(:display_name => "Jurisdiction with Election")
      
      # create 9 districts, and make them part of the Jurisdiction
      9.times do |i|
        d = District.make(:display_name => "district_#{i}", :jurisdiction => @jurisdiction_ds)
      end  
    end
    
    should "have a set of Districts that all belong to DistrictSet jurisdiction_ds" do
     (0..8).each do |i|
        dist = District.find_by_display_name("district_#{i}")
        assert !dist.nil?
        assert_valid dist
        assert_equal @jurisdiction_ds, dist.jurisdiction
      end
    end
    
    context "and election in that jurisdiction" do
      setup do
        # create an election
        @election = Election.make(:display_name => "Election 1", :district_set => @jurisdiction_ds)
      end

      # Notice that we say @election.district_set.jur_districts. In english this is saying, "For this election (@election), given the jurisdiction
      # that it is in (@election.district_set), tell me all the districts that exist in that jurisdiction (@election.district_set.jur_districts).
      # TODO: When we separate out the role of jurisdiction from district_set, this would look like
      # assert_equal 9, @election.jurisdiction.districts)
      should "pertain to that set of districts" do
        assert_equal 9, @election.district_set.jur_districts.size
      end
      
      context "and DistrictSet with 6 districts" do
        setup do        
          # create a district set has the first 6 districts created above
          split_ds = DistrictSet.make(:display_name => "split_ds")
           (3..5).to_a.each do |i|        
            split_ds.districts << District.find_by_display_name("district_#{i}")
          end
          
          # create a precinct with this district set
          @precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => @jurisdiction_ds)
          
          # create a precinct_split with this district set and precinct
          @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1", :precinct => @precinct, :district_set => split_ds)
        end

        # GOOD
        should "have 3 districts that in the election and the precinct_split" do
          common_districts = @election.district_set.jur_districts & @precinct_split.district_set.districts
          assert_equal 3, common_districts.size
          d3 = District.find_by_display_name("district_3")
          d4 = District.find_by_display_name("district_4")
          d5 = District.find_by_display_name("district_5")
          assert_same_elements common_districts,[d3,d4,d5] 
        end
        
        # GOOD
        should "have 1 precinct " do
          assert_equal 1, @election.district_set.precincts.size
        end
        
        # GOOD
        should "have 1 precinct_split " do
          assert_equal 1, @election.precinct_splits.size
        end
        
        # GOOD
        should "also have 1 precinct_split " do
          assert_equal 1, @election.district_set.precinct_splits.size
        end
      end
    end
  end 
end