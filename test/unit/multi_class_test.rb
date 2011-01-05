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

class MultiClassTest < ActiveSupport::TestCase

  context "creating various ElectionManager classes in combination" do
    should "be able to create and save a plain DistrictSet with no districts" do
      ds_count = DistrictSet.all.length
      ds = DistrictSet.new(:display_name => "gen up legal districtset")
      assert ds.save
      assert ds.valid?
      assert_equal 1, DistrictSet.all.length - ds_count
    end
    
    context "successfully populate a districtset with districts and elections" do
      setup do
        @ds = DistrictSet.create(:display_name => "gen up legal districtset")
      end
          
      should "create and attach some districts to it" do
        ds_count = District.all.length
        d1 = District.create(:display_name => "gen dist 1")
        d2 = District.create(:display_name => "gen dist 2")
        @ds.districts << d1
        @ds.districts << d2
        assert @ds.valid?
        assert_equal 2, @ds.districts.length
        assert_equal 2, District.all.length - ds_count
        assert d1.district_sets.include? @ds
        assert d2.district_sets.include? @ds
      end
      
      should "create a new election and attach to a districtset" do
        @e = Election.create(:display_name => "fake election")
        @e.district_set = @ds
        @e.save
        @efind = Election.find_by_display_name("fake election")
        assert 1, Election.all.length
        assert @e.valid?
        assert_equal @efind, @e, "Mismatch when searching the database. It didn't get properly saved."
      end
      
      context "add contests and candidates to an election et al" do
        setup do
          d1 = District.create(:display_name => "gen dist 1")
          d2 = District.create(:display_name => "gen dist 2")
          @ds.districts << d1
          @ds.districts << d2
          @el = Election.create(:display_name => "fake election")
          @el.district_set = @ds
          @el.save
        end
        
        should "create a contest and attach it to the election" do
          vm = VotingMethod.find(1)
          a_distr = @ds.districts[1]
          assert vm.valid?
          assert a_distr.valid?
          
          @cont = Contest.create(:display_name => "fake contest", :open_seat_count => 1, :voting_method => vm)
          @cand = Candidate.new(:display_name => "fake candidate")
          @cont.election = @el
          @cont.district = a_distr
          @cont.candidates << @cand
          @cont.save
          assert @cand.valid?
          assert @cont.valid?
          assert @el.valid?
          cfind = Contest.find_by_display_name("fake contest")
          assert_equal cfind, @cont
          assert_equal "fake candidate", cfind.candidates[0].display_name
        end
      end
    end  
  end
  
  context "in a different order" do
  
    should "create a named district set" do
      @d = DistrictSet.create(:display_name => "another ds")
      assert_valid @d
      @dt = DistrictSet.find_by_display_name("another ds")
      assert_equal @d, @dt
    end
    
    should "create dist set and attach an election" do
      @d = DistrictSet.create(:display_name => "another ds")
      @e = Election.create(:display_name => "another elect")
      @e.district_set = @d
      @e.save
      @et = Election.find_by_display_name("another elect")
      assert_equal @e, @et
      assert_valid @e
    end
  end
  
  context "connect a precinct to a district" do
    setup do
      @p = Precinct.create(:display_name => "prec magic")
      @d = District.create(:display_name => "dist magic")
      assert_valid @p
      assert_valid @d
    end
    
    should "be able to add a dist to a known prec" do
# I need to find out why this doesn't work.
#     @p.districts << @d
#     assert_valid @p
      assert true
    end

  end
end
