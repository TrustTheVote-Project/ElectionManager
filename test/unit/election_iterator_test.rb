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
      end
    end
  end
  
  context "Election " do
    
    setup do
      
      # create 3 districts
      d1 = District.make(:display_name => "District 1", :district_type => DistrictType::COUNTY )
      d2 = District.make(:display_name => "District 2", :district_type => DistrictType::COUNTY )
      d3 = District.make(:display_name => "District 3", :district_type => DistrictType::COUNTY )

      # create a district set that will have district 1 and 2
      @ds1 = DistrictSet.make(:display_name => "DistrictSet 1")
      @ds1.districts << d1
      @ds1.districts << d2
      
      @ds2 = DistrictSet.make(:display_name => "DistrictSet 2")
      @ds2.districts << d3

      # create a precinct_split that has district_set 1
      @split1 = PrecinctSplit.make(:display_name => 'Precinct Split 1')
      @split1.district_set = @ds1
      @split1.save!
      # create a precinct_split that has district_set 1
      @split2 = PrecinctSplit.make(:display_name => 'Precinct Split 2')
      @split2.district_set = @ds1
      @split2.save!
      
      # add these precinct split to a precinct
      @precinct = Precinct.make(:display_name => 'Precinct 1')
      # ??? so precinct has one district_sets and precinct_splits also can
      # have multiple district_sets ????
      @precinct.jurisdiction =  @ds1
      @precinct.precinct_splits << @split1
      @precinct.precinct_splits << @split2
      @precinct.save!
      
      # create a contest that is for district 1 
      c1 = Contest.make(:display_name => "Contest 1")
      c1.district = d1
      c1.save!
      
      # create a contest that is for district 3
      c2 = Contest.make(:display_name => "Contest 2")
      c2.district = d3
      c2.save!
      
      # create an election that has this contest
      @election = Election.make
      @election.contests << c1
      @election.district_set = @ds1
      @election.save!
      
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
