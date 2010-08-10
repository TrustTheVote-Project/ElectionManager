require 'test_helper'
require 'ttv/xml_to_edh'
require 'yaml'

class XMLToEDHTest < ActiveSupport::TestCase
  
  context "An XML file and conversion object" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_pre_processing.xml")
      @converter = TTV::XMLToEDH.new(@file)
      @election_data_hash = @converter.convert
      @xml_root = @converter.xml_root
    end
    
    should "pluralize element names" do
      # No way to rename elements w/ REXML. See nokogiri Node's node_name= function
      # Currently doing pluralization post-hash conversion
      assert @election_data_hash['body']['districts']
      assert @election_data_hash['body']['precincts']
      assert @election_data_hash['body']['elections']
      assert @election_data_hash['body']['candidates']
      assert @election_data_hash['body']['jurisdictions']

    end
  
    should "add empty elements for singleton elements" do
      assert @xml_root.get_elements('body/district').size > 1
      assert @xml_root.get_elements('body/precinct').size > 1
      assert @xml_root.get_elements('body/election').size > 1
      assert @xml_root.get_elements('body/election')[0].get_elements('contest').size > 1
      assert @xml_root.get_elements('body/candidate').size > 1
      
      puts YAML.dump @election_data_hash
    end
  end
end 
