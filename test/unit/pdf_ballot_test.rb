require 'test_helper'

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
