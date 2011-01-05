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


class PrecinctTest < ActiveSupport::TestCase
  context "basic test" do  
    setup do
      @precinct = Precinct.create!(:display_name => "precinct1")
    end
    
    should_create :precinct
    should_change("the number of precincts", :by => 1) { Precinct.count}    
    should_have_class_methods :find
    should_have_instance_methods :before_validation, :districts_for_election
    # should have_db_column :display_name
    # should have_db_column :ident
    should_have_attr_reader :display_name
    # should ensure_length_of(:display_name).is_equal_to(9).with_message(/is invalid/)
    should "have an identity" do
      assert !@precinct.ident.blank?
    end    
  end
  
  setup_precincts do    
    should "@p1 have 1 split" do
      assert_equal 1, @p1.precinct_splits.length
    end
    
    should "have 3 disricts in that split" do
      assert_equal 3,  @p1.precinct_splits[0].district_set.districts.count
    end
    
    context "Jurisdiction and its Precinct" do
      setup do
        @fix = setup_jurisdiction "MyJurisdiction"
      end
      
      should "have correct associations" do
        assert @fix[:jurisdiction].precincts.member? @fix[:precinct]
      end
      should "count the right number of precincts" do
        assert_equal 1, @fix[:jurisdiction].precincts.count
      end
      
    end  
  end
end
