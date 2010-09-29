require 'test_helper'

class BallotTest < ActiveSupport::TestCase
  context "Ballot" do

    setup do
      common_jurisdiction = DistrictSet.make(:display_name => "common_jurisdiction")
      
      # create 9 districts
      9.times do |i|
        common_jurisdiction.districts << District.make(:display_name => "district_#{i}")
      end        
      @precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => common_jurisdiction)
      @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1",:precinct => @precinct, :district_set => common_jurisdiction)
      
      @election = Election.make(:display_name => "Election 1", :district_set => common_jurisdiction)
    end
    
    context "Creation" do
      setup do
        # create the ballot
        @ballot = Ballot.create(:election => @election, :precinct_split => @precinct_split)
      end
      
      subject { Ballot.first}
      should_create :ballot
      should_change("the number of ballots", :by => 1){ Ballot.count}
      should_have_instance_methods :election, :precinct_split
      should_belong_to :election
      should_belong_to :precinct_split
      # should_validate_presence_of :election
      # should_validate_presence_of :precinct_split
      # should_require_attributes :election, :precinct_split
      # should_have_indices [:election, :precinct_split]
    end
    context "Find Create by Election" do
      setup do
        Ballot.find_or_create_by_election(@election)        
      end
      
      should_create :ballot    
      subject { Ballot.first}
      should_change("the number of ballots", :by => 1){ Ballot.count}
      should_have_instance_methods :election, :precinct_split
      should_belong_to :election
      should_belong_to :precinct_split      
      
      should "have a ballot for this election/precinct split pair" do
        assert_equal @election, subject.election
        assert_equal @precinct_split, subject.precinct_split
      end
      
      should "have the correct districts" do
        assert_equal 9, subject.districts.size
        
        districts = []
        9.times do |i|
          districts << District.find_by_display_name("district_#{i}")
        end        
        assert_same_elements districts, subject.districts
        
      end
    end
    
#     context "Contests" do
#       setup do
#         @ballot = Ballot.create(:election => @election, :precinct_split => @precinct_split)

#         # create 9 contests one in each district. 
#         9.times do |i|
#           # each contest will have 3 candidates name
#           # "contest_#{i}_dem","contest_#{i}_repub", "contest_#{i}_ind"
#           create_contest("contest_#{i}", VotingMethod::WINNER_TAKE_ALL, District.find_by_display_name("district_#{i}"), @election)
#         end
#       end

#       should "be those defined by the ballot districts" do
#         assert_equal 3,  @ballot.contests.size
#         contest_names = @ballot.contests.map(&:display_name)
#         [3,4,5].each do |i|
#           assert contest_names.include?("contest_#{i}")
#         end
#       end

#     end # end Contests context
    
    def add_three_contests
      # create 3 district sets each with 3 districts
      #       3.times do |i|
      #         district_set = DistrictSet.make(:display_name => "district_set_#{i}")
      #         3.times do |j|
      #           d = (i*3)+j
      #           district_set.districts << District.find_by_display_name("district_#{d}")
      #         end
      #       end

      
    end
    
  end # end Ballot context
end
