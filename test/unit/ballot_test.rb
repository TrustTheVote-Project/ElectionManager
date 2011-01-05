# OSDV Election Manager - Unit Test
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require File.dirname(__FILE__) + '/../test_helper'

class BallotTest < ActiveSupport::TestCase
  context "Ballot" do

    setup do
      @common_jurisdiction = DistrictSet.make(:display_name => "common_jurisdiction")
      
      # create 9 districts
      9.times do |i|
        @common_jurisdiction.districts << District.make(:display_name => "district_#{i}")
      end
      
      @split_ds = DistrictSet.make(:display_name => "split_ds")
      (3..5).to_a.each do |i|
        @split_ds.districts << District.find_by_display_name("district_#{i}")
      end
      
      @precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => @common_jurisdiction)
      
      # NOTE: the precinct_split has a subset of the jurisdiction's districts
      @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1",:precinct => @precinct, :district_set => @split_ds)
      
      @election = Election.make(:display_name => "Election 1", :district_set => @common_jurisdiction)
    end
    
    context "Districts" do
      should "be part of the jurisdiction" do
        9.times do |i|
          district = District.find_by_display_name("district_#{i}")
          assert_equal @common_juridiction, district.jurisdiction
        end        
      end
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
      should_validate_presence_of :election
      should_validate_presence_of :precinct_split
      # should_require_attributes :election, :precinct_split
      # should_have_indices [:election, :precinct_split]
      should "have 3 districts " do
        assert_equal 3, @ballot.districts.size
        assert_equal @split_ds.districts, @ballot.districts
      end

      should "have a default ballot file name" do
        assert_equal "#{@precinct_split.display_name}", subject.filename
      end

      should "be able to set the filename with a block with arity 0" do
        fname = subject.filename do
          "#{precinct_split.display_name.gsub(/ /,'-')}"          
        end
        assert_equal "#{@precinct_split.display_name.gsub(/ /, '-')}", fname
      end

      should "be able to set the filename with a block with arity > 0" do
        fname = subject.filename do |ballot|
          ballot.filename = "#{ballot.precinct_split.display_name.gsub(/ /,'-')}"          
        end
        assert_equal "#{@precinct_split.display_name.gsub(/ /, '-')}", fname
      end

      
      should "be able to set the filename with a ballot rule" do
        # DC.ballot_filename returns a Proc, that implements the
        # ballot naming strategy
        # We cast it to a Block
        # and pass it Ballot#filename
        # where it gets eval in the scope of a ballot
        fname = subject.filename(&TTV::BallotRule::DC.new.ballot_filename)
        assert_equal "#{@precinct_split.display_name.gsub(/split-/, 'P').gsub(/ /,'-')}", fname
      end

    end
    
    context "find_or_create_by_election" do

      should "create one ballot if none exist" do 
        assert_equal 0, Ballot.count
        ballots = Ballot.find_or_create_by_election(@election)
        assert_equal 1, Ballot.count        
        assert_equal 1, ballots.length
      end
      
      should "not create a ballot " do
        assert_equal 0, Ballot.count 
        ballot = Ballot.create(:election => @election, :precinct_split => @precinct_split)
        ballots_found = Ballot.find_or_create_by_election(@election)

        assert_equal 1, Ballot.count
        assert_equal 1, ballots_found.length
        assert_equal ballot, ballots_found.first
        assert_equal ballot.id, ballots_found.first.id
        #assert_equal ballot.created_at, ballots_found.first.created_at, "created_at error"
        #assert_equal ballot.updated_at, ballots_found.first.updated_at, "updated_at error"
      end
    end
    context "find_or_create_by_election" do
      setup do
        @ballots_found = Ballot.find_or_create_by_election(@election)
        @ballot = @ballots_found.first
      end
      subject { Ballot.first}
      
      should "ballot should be the correct election/precinct split pair" do
         assert_equal @election, subject.election
         assert_equal @precinct_split, subject.precinct_split
      end

      should "have the correct set of districts" do
        assert_same_elements @split_ds.districts, subject.districts
        assert_same_elements @precinct_split.district_set.districts, subject.districts
        
        # intersection of jurisdiction district and ballot's districts
        common_districts = @precinct.jurisdiction.districts &  subject.districts
        # should be the ballots districts. Ballot districts MUST be in
        # the jurisdiction that's tied to the election and precinct
        assert_same_elements common_districts, subject.districts

      end
    end
    context "mulitple ballots" do
      setup do
        @split_ds2 = DistrictSet.make(:display_name => "split_ds2")
        (1..3).to_a.each do |i|
        @split_ds2.districts << District.find_by_display_name("district_#{i}")
        end
      
        @precinct2 = Precinct.make(:display_name => "Precinct 2", :jurisdiction => @common_jurisdiction)
        
        # NOTE: the precinct_split has a subset of the jurisdiction's districts
        @precinct_split2 = PrecinctSplit.make(:display_name => "Precinct Split 2",:precinct => @precinct2, :district_set => @split_ds2)
        
        # create the ballot
        @ballot1 = Ballot.create(:election => @election, :precinct_split => @precinct_split)
      end
      should "find_or_create" do
        # created in setup
        assert_equal 1, Ballot.count

        # shd find one ballot, for precinct_split1,  and create one
        # ballot, for precinct_split2
        ballots_found = Ballot.find_or_create_by_election(@election)
        assert_equal 2, Ballot.count
        assert_equal 2, ballots_found.size

        ballots = Ballot.all
        ballot1 = ballots.first
        ballot2 = ballots.last
        
        assert ballot1
        assert ballot2

        assert_equal @precinct_split, ballot1.precinct_split
        assert @precinct_split2, ballot2.precinct_split
        
      end
      
    end
    context "election destruction" do
      setup do
        # create another district set
        @split_ds2 = DistrictSet.make(:display_name => "split_ds2")
        (1..3).to_a.each do |i|
        @split_ds2.districts << District.find_by_display_name("district_#{i}")
        end
      
        @precinct2 = Precinct.make(:display_name => "Precinct 2", :jurisdiction => @common_jurisdiction)
        
        # NOTE: the precinct_split has a subset of the jurisdiction's districts
        @precinct_split2 = PrecinctSplit.make(:display_name => "Precinct Split 2",:precinct => @precinct2, :district_set => @split_ds2)
        
        # create two ballots
        @ballot1 = Ballot.create(:election => @election, :precinct_split => @precinct_split)
        @ballot2 = Ballot.create(:election => @election, :precinct_split => @precinct_split2)

      end

      should "remove it's  ballots " do
        assert 2, Ballot.count
        @election.destroy
        assert_equal 0, Ballot.count
      end
    end
    context "precinct_split destruction" do
      setup do
        # create another district set
        @split_ds2 = DistrictSet.make(:display_name => "split_ds2")
        (1..3).to_a.each do |i|
        @split_ds2.districts << District.find_by_display_name("district_#{i}")
        end
      
        @precinct2 = Precinct.make(:display_name => "Precinct 2", :jurisdiction => @common_jurisdiction)
        
        # NOTE: the precinct_split has a subset of the jurisdiction's districts
        @precinct_split2 = PrecinctSplit.make(:display_name => "Precinct Split 2",:precinct => @precinct2, :district_set => @split_ds2)
        
        # create two ballots
        @ballot1 = Ballot.create(:election => @election, :precinct_split => @precinct_split)
        @ballot2 = Ballot.create(:election => @election, :precinct_split => @precinct_split2)

      end

      should "remove it's ballots " do
        assert 2, Ballot.count
        @precinct_split2.destroy
        assert_equal 1, Ballot.count
        assert_equal @ballot1, Ballot.first
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
