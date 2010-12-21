# OSDV Election Manager - Structured Macros Test
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
require 'test_helper'

# Structured Builders are the methods defined in ttv_structured_datamodel_macros.rb, which facilitate the creation of 
# complicated structured test data.

class StructuredMacrosTest < ActiveSupport::TestCase
  context "structured setup macros" do
    
    setup do
      @juris = DistrictSet.create(:display_name => "Juris")
    end
    
    should "create a singleton Jurisdiction" do
      result = setup_juris_structured(["Single J", []])
      assert_equal DistrictSet, result[0].class
    end
    
    should "create a pretty complicated case" do
      struct = ["Jur", [["Prec1", [["Split1", ["Dist1", "Dist2"]]]],
                        ["Prec2", [["Split2", ["Dist3", "Dist4", "Dist5"]]]]]]
      result = setup_juris_structured(struct)
      assert_equal DistrictSet, result[0].class
      assert_equal 2, result[1].length
    end
    
    should "be able to create districts" do
      dc = District.count
      new_dist = setup_district_structured("A district", @juris)  		
      assert_equal dc+1, District.count
      assert_equal new_dist, District.last
      assert_equal "A district", new_dist.display_name
      assert_equal @juris, new_dist.jurisdiction
      assert_valid new_dist
    end
    
    should "be able to create precinct_splits" do
      prec = Precinct.create(:display_name => "Prec")
      psc = PrecinctSplit.count
      dc = District.count
      struct = ["PrecSplit", ["distx", "disty"]]
      result = setup_precinct_split_structured(struct, @juris)
      new_ps = result[0]
      assert !new_ps.new_record?
      new_ps.districts.each { |d| assert !d.new_record? }
      assert_equal psc+1, PrecinctSplit.count
      assert_equal new_ps, PrecinctSplit.last
      assert_equal "PrecSplit", new_ps.display_name
      assert_equal dc+2, District.count
      assert_valid new_ps

# Check that the setup_precinct_split_structured returned the two District objects that were created
      assert 2, result[1]
      result[1].each {|d| assert_equal District, d.class }
    end
    
    context "structured build of whole precinct" do
      setup do
        @str = ["Prec1", [["PrecSplit1", ["dist1", "dist2"]],
               ["PrecSplit2", ["dist3", "dist4", "dist5"]]]]
      end
      
      should "create the right number of Precicts, PrecinctSplits, Districts and DistrictSets" do
        pc = Precinct.count
        psc = PrecinctSplit.count
        dc = District.count
        dsc = DistrictSet.count
        prec = setup_precinct_structured(@str, @juris)
        
        assert pc+1, Precinct.count
        assert psc+2, PrecinctSplit.count
        assert dc+5, District.count
        assert dsc+2, DistrictSet.count
      end
      
      should "contruct the right number of precinct splits" do
        result = setup_precinct_structured(@str, @juris)
        
        # Check that the Precinct created indeed has two PrecinctSplits
        assert 2, result[0].precinct_splits.count
        
        # Also check that the result returned by setup_precinct_structured contains two PrecinctSplits
        assert 2, result[1].length
        result[1].each  { |ps| assert_equal PrecinctSplit, ps[0].class}
      end
      
      should "construct the right districts in the right places" do
        result = setup_precinct_structured(@str, @juris)
        assert 5, result[0].collect_districts.count
      end
    end
    
  end
end



