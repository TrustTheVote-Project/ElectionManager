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
      assert precinct
      assert district
      assert_equal district, precinct.districts[0]
      assert_equal @jurisdiction.display_name, district.district_sets[0].display_name
    end
    
    context "exported YAML and XML" do
      setup do
        exporter = TTV::Export.new
        @yaml_export = exporter.export_jurisdiction(@jurisdiction, :yaml)
        @yaml_exported_hash = YAML.load(@yaml_export)

        exporter = TTV::Export.new
        @xml_export = exporter.export_jurisdiction(@jurisdiction, :xml)
        xml_converter = TTV::XMLToEDH.new(@xml_export)
        @xml_hash = xml_converter.convert
        @xml_exported_hash = YAML.load(@xml_export)  
      end
      
      should "export loadable YAML/XML" do
        assert @yaml_exported_hash
        assert @xml_exported_hash
      end
      
      should "contain the same data as the original hashes" do
        assert_equal 1, @yaml_export_hash['body']['jurisdictions'].size
        assert_equal 1, @xml_export_hash['body']['jurisdictions'].size
        assert_equal "State of New Hampshire", @yaml_export_hash['body']['districts'][0]['display_name']
        assert_equal "State of New Hampshire", @xml_export_hash['body']['districts'][0]['display_name']

      end
    end
    
    context "having exported XML" do
      setup do
      end
      
      should "export loadable XML" do
      end
      
      should "contain similar data" do
      end
    end
  end
end

