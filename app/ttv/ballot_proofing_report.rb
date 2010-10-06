# ballot_proofing_report.rb: Construct ballot proofing report
# Author: Pito Salas
# Date: Sept 28, 2010
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

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Brian Jordan, John Sebes, Jeffrey Gray
#
# Manage the generation of the Ballot Proofing report
#
class BallotProofingReport

  # Call before any ballot_entry calls
  def begin_listing
    
  end
  
  # Call this once for every ballot in the proofing report
  def ballot_entry precinct_split, election, contest_list, question_list, file_name

  end
  
  # Call this at the end, to actually return the ballot proofing report, as a csv
  # <tt>returns:</tt>text string corresponding to the ballot proofing report.
  def end_listing
    ""
  end
end