require 'test_helper'

class PartyTest < ActiveSupport::TestCase
  
  context "creation" do
    setup do
      @democrat_party = Party.make(:democrat)
    end
    
    should "have an ident and display_name" do
      assert @democrat_party.ident
      assert @democrat_party.display_name
      assert_equal "Democrat", @democrat_party.display_name
    end
  end
  
  def test_dbLoaded
    assert_not_nil Party.find(1), "Parties have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=test"
  end

  def test_xml_representation
    Party.find(:all).each do |dt|
      assert_equal(Party.xmlToId(dt.idToXml), dt.id, "Party type xml representations")
    end
  end

end
