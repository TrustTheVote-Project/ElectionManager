require 'test_helper'
require "voting_method"

class VotingMethodTest < ActiveSupport::TestCase
 
  def test_dbLoaded
    assert_not_nil VotingMethod.find(1), "VotingMethods have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=test"
  end

  def test_xml_representation
    VotingMethod.find(:all).each do |dt|
      assert_equal(VotingMethod.xmlToId(dt.idToXml), dt.id, "VotingMethod xml representations")
    end
  end

end
