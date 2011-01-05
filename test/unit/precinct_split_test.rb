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

class PrecinctSplitTest < ActiveSupport::TestCase
  
  context 'Precinct Split' do
    setup do
      @dist_set = DistrictSet.make(:display_name => "some districts")
    end
    
    
    should "accept an attached Precinct" do
      assert_equal 0, PrecinctSplit.count
      prec_split = PrecinctSplit.make(:district_set => @dist_set)
      
      prec = Precinct.make
      prec.precinct_splits << prec_split
      
      assert_equal 1, prec.precinct_splits.length
      assert_equal 1, PrecinctSplit.count
    end
    
    context "iterators" do
      setup do
        setup_test_election
      end
    
      should "correctly return ballot contests" do
        # ap @split1.ballot_contests(@election)
        # puts 1
      end 
    end    
  end
end
