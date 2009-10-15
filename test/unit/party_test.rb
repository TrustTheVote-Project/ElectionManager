require 'test_helper'

class PartyTest < ActiveSupport::TestCase
  
  def test_dbLoaded
    assert_not_nil Party.find(1), "Parties have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=test"
  end

  def test_xml_representation
    Party.find(:all).each do |dt|
      assert_equal(Party.xmlToId(dt.idToXml), dt.id, "Party type xml representations")
    end
  end

end
