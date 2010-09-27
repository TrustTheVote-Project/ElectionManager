require 'test_helper'

class BallotTest < ActiveSupport::TestCase
  context "Ballot" do

    setup do
      # create 9 districts
      9.times do |i|
        District.make(:display_name => "district_#{i}")
      end
      
      # create 3 district sets each with 3 districts
      #       3.times do |i|
      #         district_set = DistrictSet.make(:display_name => "district_set_#{i}")
      #         3.times do |j|
      #           d = (i*3)+j
      #           district_set.districts << District.find_by_display_name("district_#{d}")
      #         end
      #       end

      # create a precinct split district set that has districts 0 - 5
      split_ds = DistrictSet.make(:display_name => "split")
      (0..5).to_a.each do |i|        
        split_ds.districts << District.find_by_display_name("district_#{i}")
      end
      precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => split_ds)
      @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1",:precinct => precinct, :district_set => split_ds)

      # create an election district set that has districts 3 - 8
      election_ds =  DistrictSet.make(:display_name => "election")
      (3..8).to_a.each do |i|
        election_ds.districts << District.find_by_display_name("district_#{i}")
      end
      
      @election = Election.make(:display_name => "Election 1", :district_set => election_ds)
    end
    
    context "Creation" do
      setup do
        @ballot = Ballot.create(:election => @election, :precinct_split => @precinct_split)
      end
      
      subject { Ballot.first}
      should_create :ballot
      should_change("the number of ballots", :by => 1){ Ballot.count}
      should_have_instance_methods :election, :precinct_split
      should_validate_presence_of :election
      should_validate_presence_of :precinct_split
    end
    context "Districts" do
      setup do
        @ballot = Ballot.create(:election => @election, :precinct_split => @precinct_split)
      end

      should "be the intersection of election and precinct split districts" do
        # ballot should have districts 3,4 and 5
        # intersection of precinct_split districts 0-5 and election
        # districts 3-8
        expected_districts = [3,4,5].inject([]) do |districts, i|
          districts << District.find_by_display_name("district_#{i}")
        end
        assert_equal expected_districts, @ballot.districts
      end
    end # end Districts context
    
    context "Contests" do
      setup do
        @ballot = Ballot.create(:election => @election, :precinct_split => @precinct_split)

        # create 9 contests one in each district. 
        9.times do |i|
          # each contest will have 3 candidates name
          # "contest_#{i}_dem","contest_#{i}_repub", "contest_#{i}_ind"
          create_contest("contest_#{i}", VotingMethod::WINNER_TAKE_ALL, District.find_by_display_name("district_#{i}"), @election)
        end
      end

      should "be those defined by the ballot districts" do
        assert_equal 3,  @ballot.contests.size
        contest_names = @ballot.contests.map(&:display_name)
        [3,4,5].each do |i|
          assert contest_names.include?("contest_#{i}")
        end
      end

    end # end Contests context
    
  end # end Ballot context
end
