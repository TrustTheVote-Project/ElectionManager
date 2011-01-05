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


# Relationships 
# jurisdiction ---E districts
# Each district must be part of only one jurisdiction.
# Each jurisdiction may contain one or more districts.

# jurisdiction ---E precincts
# Each precinct must be part of only one jurisdiction.
# Each jurisdiction may contain one or more precincts.

# jurisdiction ---- election
# Each election is conducted for only one jurisdiction
# Each jurisdiction conducts only one election.

# precinct split ---- district set
# Each precinct split may be associated with only one district set
# ???
# Each district set may be associated with one or more precinct splits?
# split
# Effectively, this means that:
# Each precinct split must be for one or more districts
# Each district may be associated with one or more precincts splits.

# precinct split ---- precinct
# Each precinct split must be part of only one precinct.
# Each precinct must contain one or more precinct splits

# TODO:  (Not currently enforced)
# Each precinct split district must be within the the precinct's
# Jurisdiction.

# TODO: Give the relationship's better semantics than "associated
# with", "for", ...


# create a jurisdiction
# this jurisdiction will contains a set of districts and precincts.
# this jurisdiciton will be associated to an election
# create a district set
# this district set will be a subset of the juridiction's districts.
# this district set will be associated with a precinct_split.
# create a precinct split
# this precinct split will be associated with a precinct and a
# district set

class ElectionPrecinctSplitTest < ActiveSupport::TestCase
  context "Jurisdiction and Districts" do

    # create the jurisdiction
    # and 9 districts
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

    # create an election for this jurisdiction
    context "and election in that jurisdiction" do
      setup do
        # create an election
        @election = Election.make(:display_name => "Election 1", :district_set => @jurisdiction_ds)
      end
      
      # TODO: When we separate out the role of jurisdiction from district_set, this would look like
      # assert_equal 9, @election.jurisdiction.districts)
      should "pertain to that set of districts" do
        assert_equal 9, @election.district_set.jur_districts.size
      end
      
      # Create a district set that has 6 districts for the above
      # juridiction. This district set will be associated with a
      # precinct split
      context "and DistrictSet with 6 districts" do
        setup do        
          # create a district set has the 3 districts from the
          # jurisdiction created above
          split_ds = DistrictSet.make(:display_name => "split_ds")
           (3..5).to_a.each do |i|        
            split_ds.districts << District.find_by_display_name("district_#{i}")
          end
          
          # create a precinct with the jurisdiction we use for
          # districts and election above.
          @precinct = Precinct.make(:display_name => "Precinct 1", :jurisdiction => @jurisdiction_ds)
          
          # create a precinct_split with this district set and
          # precinct. The district set we associate with this precinct
          # split is NOT the jurisdiction district set.
          @precinct_split = PrecinctSplit.make(:display_name => "Precinct Split 1", :precinct => @precinct, :district_set => split_ds)
        end

        should "have 3 districts that in the election and the precinct_split" do
          common_districts = @election.district_set.jur_districts & @precinct_split.district_set.districts
          assert_equal 3, common_districts.size
          d3 = District.find_by_display_name("district_3")
          d4 = District.find_by_display_name("district_4")
          d5 = District.find_by_display_name("district_5")
          assert_same_elements common_districts,[d3,d4,d5] 
        end
        
        should "have 1 precinct  " do
          assert_equal 1, @election.district_set.precincts.size
        end

        should "have 1 precinct_split " do
          assert_equal 1, @election.precinct_splits.size
        end
        
        should "also have 1 precinct_split " do
          assert_equal 1, @election.district_set.precinct_splits.size
        end
      end
    end
  end 
end
