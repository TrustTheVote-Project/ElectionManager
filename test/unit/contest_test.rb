require 'test_helper'

class ContestTest < ActiveSupport::TestCase

  context 'Contest class' do
    
    setup do
      @election =  create_election_first
      @voting_method = VotingMethod.create(:display_name =>"Winner Take All")
    end
    
    should 'able to create a new contest' do

      contest = Contest.new(:display_name => "State Representative")
      contest.voting_method =  @voting_method
      contest.district =  @election.district_set.districts.first
      contest.election =  @election
      
      assert contest.save
    end
    
    should 'store and retreive a contest order' do
      contest = Contest.new(:display_name => "State Representative")
      contest.voting_method =  @voting_method
      contest.district =  @election.district_set.districts.first
      contest.election =  @election
      contest.position = 5
      
      assert contest.save
      assert_equal 5, contest.position
    end
  end

  context "An existing contest" do

    setup do
      create_contest
    end
    
    subject { Contest.last}
    should_create :contest
    should_belong_to :election
    should_belong_to :district
    should_belong_to :voting_method
    
    should  "be part of an election" do
      election = Election.find_by_display_name("2008 Massachusetts State")
      
      # should be the only contest in the election
      assert_equal election.contests.first, subject
      assert_block{ election.contests.size == 1 }
      
      # test a searchlogic named scope
      assert_equal 1, Contest.election_display_name_is(election.display_name).size
    end
    
    should 'not be part of all elections' do
      election_last = create_election_last
      assert_block{ election_last.contests.size == 0 }
      
      # test a searchlogic named scope
      assert_equal 0, Contest.election_display_name_is(election_last.display_name).size
    end

    should "find contests by election name" do

      contests  = Contest.election_display_name_is("2008 Massachusetts State")
      assert_equal 1, contests.size
    end
    
    should "find contests by precinct name" do
      precinct = Precinct.find_by_display_name "Chelmsford Precinct 3"
      prec_districts = precinct.collect_districts
      district = Contest.display_name_is("State Representative")[0].district
      assert prec_districts.member? district
    end
    
  end
  
  # TODO: Should be replaced by factories, factory-girl or machinist
  def create_contest

    voting_method = VotingMethod.create!(:display_name =>"Winner Take All")
    
    election = create_election_first
    
    contest = Contest.new(:display_name => "State Representative")
    contest.voting_method =  voting_method
    contest.district =  election.district_set.districts.first
    contest.election =  election
    contest.save!
    return contest
  end

  def create_election_first
    
    prec_1 = setup_precinct "Chelmsford Precinct 3", 4
    prec_2 = setup_precinct "Chelmsford Precinct 5", 2
    prec_3 = setup_precinct "Chelmsford Precinct 7", 3


    all_dist = prec_1.collect_districts | prec_2.collect_districts | prec_3.collect_districts
    district_set = DistrictSet.new(:display_name =>"MiddleSex County")
    district_set.districts << all_dist
    Election.create!(:display_name => "2008 Massachusetts State", :district_set => district_set)
  end
  
  def create_election_last
    prec_4 = setup_precinct "Chelmsford Precinct 77", 4
    prec_5 = setup_precinct "Chelmsford Precinct 99", 4
    prec_6 = setup_precinct "Chelmsford Precinct 88", 4

    all_dist = prec_4.collect_districts | prec_5.collect_districts | prec_6.collect_districts
    district_set = DistrictSet.new(:display_name => "Suffolk County")
    district_set.districts << all_dist
    Election.create(:display_name => "2012 County", :district_set => district_set)     
  end
  
end
