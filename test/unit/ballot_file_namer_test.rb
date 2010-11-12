# OSDV Election Manager - Unit Test
# Author: FillMeIn
# Date: FillMeIn
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

class BallotFileNamerTest < ActiveSupport::TestCase
  context "BallotFileNamer" do
    setup do
      @bnf = BallotFileNamer.new
      setup_test_election
    end
    
    should "work in default case" do
      assert_equal "Precinct-1-Precinct-Split-1", @bnf.ballot_file_name(@split1, @election)
    end
  end
end

  
  
