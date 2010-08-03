require 'test_helper'
require 'ttv/xml_to_edh'

class XMLToEDHTest < ActiveSupport::TestCase
  
  context "An XML file and conversion object" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/simple_xml.xml")
      @converter = TTV::XMLToEDH.new(@file)
    end
    
    should "be instantiated with a hash" do
      assert @converter.xml_hash
      puts YAML.dump(@converter.xml_hash)
    end
    
    should "represent jurisdiction display name" do
      @converter.convert
      assert_equal  @converter.xml_hash["election"]["districts"]["display_name"],
                    @converter.election_data_hash["ballot_info"]["jurisdiction_display_name"]
    end
    
    should "generate a district lookup table that finds all districts by precinct" do
      # TODO
    end
    
    should "generate precinct list" do
      # TODO
    end
  end
end