require 'test_helper'
require 'ttv/xml_to_edh'
require 'yaml'
require 'rexml/document'

class XMLToEDHTest < ActiveSupport::TestCase
  context "An XML file and conversion object" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_pre_processing.xml")
      @converter = TTV::XMLToEDH.new(@file)
      @election_data_hash = @converter.convert
      @xml_root = @converter.xml_root
    end
    
    should "pluralize element names" do
      assert @election_data_hash['body']['districts']
      assert @election_data_hash['body']['districts'][0]['jurisdictions']
      assert @election_data_hash['body']['precincts']
      assert @election_data_hash['body']['precincts'][0]['districts']
      assert @election_data_hash['body']['elections']
      assert @election_data_hash['body']['elections'][0]['contests']
      assert @election_data_hash['body']['candidates']
      assert @election_data_hash['body']['jurisdictions']
      assert @election_data_hash['body']['contests']
    end
  
    should "add empty elements for singleton elements" do
      assert @xml_root.get_elements('body/district').size > 1
      assert @xml_root.get_elements('body/district')[0].get_elements('jurisdiction').size > 1
      assert @xml_root.get_elements('body/contest').size > 1
      assert @xml_root.get_elements('body/precinct').size > 1
      assert @xml_root.get_elements('body/precinct')[0].get_elements('district').size > 1
      assert @xml_root.get_elements('body/election').size > 1
      assert @xml_root.get_elements('body/election')[0].get_elements('contest').size > 1
      assert @xml_root.get_elements('body/candidate').size > 1
      
    end
    
    should "remove empty elements after hash conversion" do
      # Test a couple, function applies to all items in hash, recursively
      assert_equal 1, @election_data_hash['body']['jurisdictions'].size
      assert_equal 1, @election_data_hash['body']['elections'][0]['contests'].size
    end
  end
  
  # This was an experiment using container tags and the "array" field to force
  # Hash.from_xml to make single items be placed in arrays.
  # No longer applicable
=begin
  context "An XML file with 'type=array's" do
    should "convert singleton fields to array elements" do
      @file = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_arrays.xml")
      @rexml = REXML::Document.new @file
      xml_result = ''
      @rexml.write(xml_result)
      @hash = Hash.from_xml xml_result
    end
  end
  
  context "An XML file without 'type=array's" do
    should "convert singleton fields to array elt's" do
      @file = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_nested.xml")
      @rexml = REXML::Document.new @file
      
      @rexml.root
      @xml_body = @rexml.root.get_elements('body')[0]

      @xml_body.each_element('contests'){|element| element.add_attribute("type", "array")}
      @xml_body.each_element('precincts'){|element| element.add_attribute("type", "array")}
      @xml_body.each_element('candidates'){|element| element.add_attribute("type", "array")}
      @xml_body.each_element('jurisdictions'){|element| element.add_attribute("type", "array")}
      @xml_body.each_element('elections'){|element| element.add_attribute("type", "array")}
      @xml_body.each_element('districts'){|element| element.add_attribute("type", "array")}
      @xml_body.each_element('districts/district/precincts'){|element| element.add_attribute("type", "array")}
      xml_result = ''
      @rexml.write(xml_result)
      @hash = Hash.from_xml xml_result
      
      # puts YAML.dump @hash      
    end
  end
=end
end 
