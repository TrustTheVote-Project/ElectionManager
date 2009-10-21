require 'test_helper'

class PDFBallotTest < ActiveSupport::TestCase
  def test_GenerateBallot
    election = Election.find(:first)
    precinct = election.district_set.precincts[12]
    pdf = TTV::PDFBallot.create(election, precinct)
    f = File.new("#{RAILS_ROOT}/test/PDFBallot.pdf", 'w')
    f.write(pdf)
    f.close
    `open /Applications/Preview.app #{f.path}`
    assert_not_nil(election)
    assert_not_nil(precinct)
  end
  
end
