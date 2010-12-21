# OSDV Election Manager - Unit Test for Ballot ...more of them
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

class BallotMoreTest < ActiveSupport::TestCase
  context "small jurisdiction" do
    setup do
      struct = ["Jur", [["Prec1", [["Split1", ["Dist1", "Dist2"]]]],
                        ["Prec2", [["Split2", ["Dist3", "Dist4", "Dist5"]]]]]]
      result = setup_juris_structured(struct)

      @juris =        result[0]
      @dist1 =        result[1][0][1][0][1][0]
      @dist2 =        result[1][0][1][0][1][1]      
      @dist3 =        result[1][1][1][0][1][0]
      @dist4 =        result[1][1][1][0][1][1]
      @dist5 =        result[1][1][1][0][1][2]
      @prec1split1 =  result[1][0][1][0][0]
    end
    
    context "ballot" do
      setup do
        @el = Election.create(:display_name => "Test")
        @ball1 = Ballot.create(:election => @el, :precinct_split => @prec1split1)
      end
      
      should "be blank if there are no contests" do
        assert_equal Ballot, @ball1.class
        assert @ball1.blank?
      end
      
      should "be non-blank with contest added to districts in precsplit1" do
        c1 = Contest.create(:display_name => "C1", :election => @el, :district => @dist1, :open_seat_count => 1, :voting_method => VotingMethod::WINNER_TAKE_ALL)
        assert c1.valid?
        assert !@ball1.blank?
        assert_equal c1, @ball1.contests[0]
      end
      
      should "be blank with contests added to districts in precsplit2" do
        c1 = Contest.create(:display_name => "C1", :election => @el, :district => @dist5, :open_seat_count => 1, :voting_method => VotingMethod::WINNER_TAKE_ALL)
        assert c1.valid?
        assert @ball1.blank?

      end
    
    end
  end
end



