require 'test_helper'

class BallotStyleTemplateSortTest < ActiveSupport::TestCase
    
  context "Ballot Rule candidate sorting" do
    setup do
      @bst = BallotStyleTemplate.make
    end

    should "sort candidates by position for the default ballot rule" do
      # randomize the candidate positions
      candidates = []
      10.times do |i|
        candidates << Candidate.make(:position => rand(10))
      end
      
      # sort them by position
      sorted_candidates = candidates.sort(&@bst.candidate_ordering)
      
      # check em
      prev = sorted_candidates.first
      sorted_candidates.each do |c|
        assert prev.position <= c.position
        prev = c
      end
    end
    
    should "sort candidates by party for the VA ballot rule" do
      
      # candidates for each party
      repub =  Candidate.make(:position => 10, :party => Party::REPUBLICAN)
      indy = Candidate.make(:position => 9, :party => Party::INDEPENDENT)
      dem = Candidate.make(:position => 7, :party => Party::DEMOCRATIC)
      indy_green = Candidate.make(:position => 3, :party => Party::INDEPENDENTGREEN)

      # jumble up candidates for each party
      candidates = [repub, indy, dem, indy_green]

      # use the VA Ballot Rule for candidate ordering
      # that is sort candidates by their party affiliation
      @bst.ballot_rule_classname = "VA"
      assert @bst.ballot_rule.instance_of?(TTV::BallotRule::VA)
      
      # sort these candidates by party
      sorted_candidates = candidates.sort(&@bst.candidate_ordering)

      # candidates shb sorted by party
      assert_equal sorted_candidates, [repub, dem, indy_green,indy]

      # include a candidate with no party
      no_party = Candidate.make(:position => 8, :party => nil)
      candidates = [repub, dem, no_party, indy_green]
      
      # sort these candidates by party
      sorted_candidates = candidates.sort(&@bst.candidate_ordering)
      
      # candidates shb sorted by party, candidates with no party will
      # be treated like they are independents
      assert_equal sorted_candidates, [repub, dem, indy_green, no_party]
      
      # sorted_candidates.each do |c|
      #   puts "TGD: sorted candidate name = #{c.display_name}"
      #   puts "TGD: sorted candidate party name = #{c.party.display_name}"
      # end
      
    end
  end
  
  context "Ballot Rule contest sorting" do
    setup do
      @bst = BallotStyleTemplate.make
    end
    
    should "sort contests by position for default ballot rule" do
      
      # randomize the contests positions
      contests = []
      10.times do |i|
        contests << Contest.make(:position => rand(10))
      end
      
      # sort them by position
      sorted_contests = contests.sort(&@bst.contest_ordering)

      # check em
      prev = sorted_contests.first
      sorted_contests.each do |c|
        assert prev.position <= c.position
        prev = c
      end

    end
    
  end
  
  context "Ballot Rule district sorting" do
    setup do
      @bst = BallotStyleTemplate.make
    end
    
    should "sort districts by position for default ballot rule" do
      
      districts = []
      10.times do |i|
        districts << District.make(:position => 10-i)
      end
      # before sorting the district are NOT sorted by position
      assert_equal [10,9,8,7,6,5,4,3,2,1], districts.map(&:position)
      sorted_districts = districts.sort(&@bst.district_ordering)
      # after sorting the district ar sorted by postion
      assert_equal [1,2,3,4,5,6,7,8,9,10], sorted_districts.map(&:position)
      
      # randomize the district positions
      districts = []
      10.times do |i|
        districts << District.make(:position => rand(10))
      end

      # sort them by position
      sorted_districts = districts.sort(&@bst.district_ordering)
      
      # check em
      prev_district = sorted_districts.first
      sorted_districts.each do |d|
        assert prev_district.position <= d.position
        prev_district = d
      end
    end
    
  end
  
end
