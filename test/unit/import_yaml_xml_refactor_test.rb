require 'test_helper'
require 'yaml'
require 'xml'

class ImportYAMLXMLRefactorTest < ActiveSupport::TestCase
  
  context "A hash-converted XML and YAML file" do
    setup do
      @xml = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_refactor_nested.xml")
      @yaml = File.new("#{RAILS_ROOT}/test/elections/refactored/yaml_refactor.yml")
      @xml_2 = File.new("#{RAILS_ROOT}/test/elections/blank.xml")
      @hash_from_xml = Hash.from_xml(@xml)
      @hash_from_xml_2 = Hash.from_xml(@xml_2)

      @hash_from_yaml = YAML::load(@yaml)
      #@converter = TTV::XMLToEDH.new(@file)
    end
    
    should "contain similar data" do
      puts "=== FROM XML ==="
      puts YAML.dump @hash_from_xml
      puts "=== FROM YAML ==="
      puts YAML.dump @hash_from_yaml
      puts "=== FROM XML, 2 ==="
      puts YAML.dump @hash_from_xml_2
    end
  
=begin    
    should "be instantiated with a hash" do
      assert @converter.xml_hash
      puts YAML.dump(@converter.xml_hash)
    end
    
    setup do
      @user =  User.make
      @juris =  DistrictSet.make
      @juris_user = JurisdictionMembership.make(:user =>@user, :district_set => @juris)
      @juris_user.save
    end
    
    should
=end 
  end

end