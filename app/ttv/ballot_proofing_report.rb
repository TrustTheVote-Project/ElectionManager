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
    @csv = FasterCSV.new ""
    @csv << ["file name", "precinct split", "precinct", "n contests", "n questions", "contest names", "question_names"]
  end
  
  # Call this once for every ballot in the proofing report
  # <tt>prec_split:</tt>precinct split for ballot
  # <tt>election:</tt>relevant election
  # <tt>file_namer:</tt>instance of BallotFileNamer which defines the names of the individual ballot files
  def ballot_entry split, election, ballot_rule
    contests = split.ballot_contests(election)
    questions = split.ballot_questions(election)
    file_name = Ballot.filename(election,split, ballot_rule)
    row = [file_name, split.display_name, split.precinct.display_name]
    row << contests.count
    row << questions.count
    row << contests.join("|")
    row << questions.join("|")
    @csv << row
  end
  
  # Call this at the end, to actually return the ballot proofing report, as a csv
  # <tt>returns:</tt>text string corresponding to the ballot proofing report.
  def end_listing
    return @csv.string
  end
end
