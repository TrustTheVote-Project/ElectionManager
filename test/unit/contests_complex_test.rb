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


class ContestsComplexTest < ActiveSupport::TestCase
  context "of Precincts and Splitsl" do
    setup do
      @pnames = ["Complex1", "Complex2"] 

      # create two precincts with one Split
      @pnames.each { |name| setup_precinct(name, 1)}
    end
    
    should "Correctly create two precincts" do
      @pnames.each do |name|
        p = Precinct.find_by_display_name(name)
        assert_valid p
        assert_valid p.precinct_splits[0]
        assert_equal name + " Split 0", p.precinct_splits[0].district_set.display_name
      end
    end
    
    should "Correctly enumerate Precinct's Districts" do
      @pnames.each do |name|
        p = Precinct.find_by_display_name(name)
        d = p.collect_districts
        assert_equal 3, d.length
      end
    end
    
    context "and Elections" do
      setup do
        @ds_for_election = DistrictSet.find_by_display_name(@pnames[0] + " Split 0")
        @enames = ["Election Alpha", "Election Beta"]
        @enames.each do |name|
          Election.create!(:display_name => name, :district_set => @ds_for_election)
        end
      end
      
      should "Correctly create two Elections" do
        @enames.each do |name|
          e = Election.find_by_display_name(name)
          assert e.valid?
        end
      end
      
      context "and Contests" do
        setup do
          @ds_out_of_election = DistrictSet.find_by_display_name(@pnames[1] + " Split 0")
          @in_cont_list = ["In Contest A", "In Contest B"]
          @out_contest_list = ["Out Contest C", "Out Contest D"]
          @in_cont_list.each do |name|
            Contest.create!(:display_name => name, :district => @ds_for_election.districts[0], :election => Election.find_by_display_name(@enames[0]))
          end
          @out_contest_list.each do |name|
            Contest.create!(:display_name => name, :district => @ds_out_of_election.districts[0], :election => Election.find_by_display_name(@enames[1]))
          end
        end
                
        should "Correctly create Contests" do
          @in_cont_list.each do |name|
            c = Contest.find_by_display_name(name)
            assert_valid c
          end
          @out_contest_list.each do |name|
            c = Contest.find_by_display_name(name)
            assert_valid c
          end
        end
        
        should "Correctly know the districts for each Election" do
          @enames.each do |name|          
            election = Election.find_by_display_name name
            election.contest_districts.each { |d| assert_valid d }
            election.collect_districts.each { |d| assert_valid d }
          end
        end
      
        should "Find the right contests with the right elections" do
          in_election = Election.find_by_display_name(@enames[0])
          in_precinct = Precinct.find_by_display_name(@pnames[0])
          assert_equal 2, Contest.contests_for_precinct_election(in_precinct, in_election).length
        end
      end
    end
  end
end #end context
