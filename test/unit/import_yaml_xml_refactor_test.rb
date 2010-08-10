require 'test_helper'
require 'yaml'
require 'xml'

class ImportYAMLXMLRefactorTest < ActiveSupport::TestCase
  
  context "A hash-converted XML and YAML file" do
    setup do
      @xml = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_pre_processing_alerts.xml")
      @yaml = File.new("#{RAILS_ROOT}/test/elections/refactored/yaml_refactor_alerts.yml")

      xml_converter = TTV::XMLToEDH.new(@xml)
      
      @hash_from_xml = xml_converter.convert
      @hash_from_yaml = YAML::load(@yaml)
    end
    
    should "contain similar data" do
      puts "=== FROM XML ==="
      puts YAML.dump @hash_from_xml
      puts "=== FROM YAML ==="
      puts YAML.dump @hash_from_yaml
    end
  end
end