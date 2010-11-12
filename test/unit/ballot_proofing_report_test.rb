# OSDV Election Manager - Ballot Proofing Report Test
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

class BallotProofingReportTests < ActiveSupport::TestCase
  context "BallotProofingReport name" do
    setup do
      @bp = BallotProofingReport.new
      @bp.begin_listing
    end
    
    should "return one line on null case" do
      assert_equal 1, @bp.end_listing.lines.count
    end
    
    context "over test_election" do
      setup do
        @bnf = BallotFileNamer.new
        setup_test_election
        @bp.ballot_entry @split1, @election, @bnf
        @bp.ballot_entry @split2, @election, @bnf
      end
      
      should "have 3 lines" do
        result = @bp.end_listing
        assert_equal "file name,precinct split,precinct,n contests,n questions,contest names,question_names", result.lines.to_a[0].chomp
        assert_equal "Precinct-1-Precinct-Split-1,Precinct Split 1,Precinct 1,1,2,CONTEST Contest 1,QUESTION: Question 1|QUESTION: Question 2", result.lines.to_a[1].chomp
        assert_equal "Precinct-1-Precinct-Split-2,Precinct Split 2,Precinct 1,1,2,CONTEST Contest 1,QUESTION: Question 1|QUESTION: Question 2", result.lines.to_a[2].chomp
        assert_equal 3, result.lines.count
      end
    end
  end
end
