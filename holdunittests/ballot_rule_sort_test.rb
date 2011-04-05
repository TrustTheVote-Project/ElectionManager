# OSDV Election Manager - Unit Test for Ballot Rule sorting
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

class BallotRuleSortTest < ActiveSupport::TestCase
  
  context "District sorting strategy" do
    setup do
      @base_class = ::TTV::BallotRule::Base.new
      @districts = []
      10.times do |i|
        @districts << District.make(:display_name => "District#{i}", :position => rand(10))
      end
    end
    
    should "by default order district by position" do
      last_position = 0
      @districts.sort(&@base_class.district_ordering).each do |district|
        assert last_position <= district.position
        last_position = district.position
      end
    end
  end # end of context
  
  context "Contest sorting strategy" do
    setup do
    end
  end
  
  context "Question sorting strategy" do
    setup do
    end
  end

end
