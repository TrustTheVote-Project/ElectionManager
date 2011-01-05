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


class PDFBallotTest < ActiveSupport::TestCase
  # TODO: Believe these tests are no longer valid??
  def pending_test_GenerateBallot
    election_to_ballot(File.new( RAILS_ROOT + "/test/elections/contests_mix.xml"), 'en')
  end
  # TODO: Believe these tests are no longer valid??  
  def pending_test_AigaBallot
    election_to_ballot(File.new( RAILS_ROOT + "/test/elections/contests_mix.xml"), 'en', 'aiga')
  end
  
# commented out because translation involves lots of network activity for Google Translation API  
  def not_test_Spanish
    election = TTV::ImportExport.import(File.new( RAILS_ROOT + "/test/elections/contests_mix.xml"))
    precinct = election.district_set.precincts.first
    lang = 'es'
    TTV::PDFBallot.translate(election, lang)
    pdf = TTV::PDFBallot.create(election, election.district_set.precincts.first, 'default', lang)
    File.open "#{RAILS_ROOT}/test/tmp/UnitTest.pdf", 'w' do |f|
      f.write(pdf)
    end
  end
  
  def election_to_ballot(file, lang = 'en', style  = 'default')
    election = TTV::ImportExport.import(file)
    precinct = election.district_set.precincts.first
    pdf = AbstractBallot.create(election, precinct, style, lang, "/images/toolbox.jpg")
    File.open "#{RAILS_ROOT}/test/tmp/UnitTest.pdf", 'w' do |f|
      f.write(pdf)
    end
  end

end
