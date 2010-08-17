require 'test_helper'
require 'ttv/export'


class ExportTest < ActiveSupport::TestCase
  context "An imported YAML/XML file" do
    setup do
      # Generate EDHs
      @yaml = File.new("#{RAILS_ROOT}/test/elections/refactored/yaml_refactor.yml")
      @yaml_hash = YAML.load(@yaml)
      
      @xml = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_pre_processing.xml")
      xml_converter = TTV::XMLToEDH.new(@xml)
      @xml_hash = xml_converter.convert
      
      # Do imports
      import_yaml = TTV::ImportEDH.new(@yaml_hash)
      import_yaml.import
          
      import_xml = TTV::ImportEDH.new(@xml_hash) # ImportEDH
      import_xml.import
    end
    
    should "have imported correctly" do
      precinct = Precinct.find_by_display_name "Bedford County"
      district = District.find_by_display_name "State of New Hampshire"
      jurisdiction = DistrictSet.find_by_display_name "New Hampshire"
      assert precinct
      assert district
      assert_equal district, precinct.districts[0]
      assert_equal jurisdiction.display_name, district.district_sets[0].display_name
    end
    
    context "having exported YAML and XML" do
      setup do
        jurisdiction = DistrictSet.find_by_display_name("New Hampshire")
        @exporter = TTV::Export.new
        @yaml_export = @exporter.export_jurisdiction(jurisdiction, :yaml)
        #@yaml_exported_hash = YAML.load(@yaml_export)

        @xml = @exporter.export_jurisdiction(jurisdiction, :xml)
        # Needs massaging see http://gist.github.com/531530
        # xml_converter = TTV::XMLToEDH.new(@xml)
        # @xml_export = xml_converter.convert # Convert to hash  
      end
      
      should "export readable YAML" do
        assert @yaml_export
      end
      
      should "export specified jurisdiction" do
        assert_equal 1, @yaml_export['body']['jurisdictions'].size
        assert_equal "New Hampshire", @yaml_export['body']['jurisdictions'][0]['display_name']
        assert_equal "1", @yaml_export['body']['jurisdictions'][0]['ident']
      end
      
      should "export districts" do
        assert_equal "State of New Hampshire", @yaml_export['body']['districts'][0]['display_name']
        assert_equal "1", @yaml_export['body']['districts'][0]['ident']
        assert_equal "1", @yaml_export['body']['districts'][0]['jurisdiction_identref']
      end
      
      should "export precincts" do
        precinct_1 = @yaml_export['body']['precincts'].detect{|precinct| precinct['ident'] == "1"}
        
        assert_equal "State of New Hampshire", precinct_1['display_name']
      end
      
      should "export elections" do
        
      end
      
    end
  end
end

