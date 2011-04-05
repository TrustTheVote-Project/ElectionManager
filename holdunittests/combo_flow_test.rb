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

class ComboFlowTest < ActiveSupport::TestCase
  setup_jurisdictions do  
    context "DefaultBallot::FlowItem::Combo" do
      setup do
        @e1 = Election.find_by_display_name "Election 1"
        @p1 = Precinct.find_by_display_name "Precint 1"
        @scanner = TTV::Scanner.new
        @lang = 'en'
        @style = "default"
        image_instructions = 'images/test/instructions.jpg'
        
        @template = BallotStyleTemplate.make(:display_name => "test template")
        @ballot_config = DefaultBallot::BallotConfig.new( @e1, @template)        
        
        @pdf = create_pdf("Test Combo Flow")
        @ballot_config.setup(@pdf,nil)
        
      end
      
      should "get the Combo flow item for Arrays" do
        assert_instance_of DefaultBallot::FlowItem::Combo, ::DefaultBallot::FlowItem.create_flow_item(@pdf,[])
      end
      
    end
  end
end
