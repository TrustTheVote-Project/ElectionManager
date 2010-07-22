require 'test_helper'
require 'ttv/alert'

class YAMLAuditTest < ActiveSupport::TestCase
  context "Election objects" do
    should "be instantiated but not saved" do
      created_precinct = Precinct.create(:display_name => "Created Precinct")
      created_result = Precinct.find_by_display_name "Created Precinct"
      assert_equal created_precinct, created_result
      
      new_precinct = Precinct.new(:display_name => "New Precinct")
      new_result = Precinct.find_by_display_name "New Precinct"
      assert_equal nil, new_result
    end
    
    should "associate with each other without being saved" do
      new_precinct = Precinct.new(:display_name => "New Precinct")

      new_district = District.new(:display_name => "New District", :district_type_id => 1)
      
      new_district.precincts << new_precinct
      
      # Precinct stored in district
      assert_equal new_precinct, new_district.precincts[0]
      
      # Neither stored in database
      assert_equal nil, Precinct.find_by_display_name("New Precinct")
      assert_equal nil, District.find_by_display_name("New District")
    end
    
    should "be collected in an array, found by ID" do
      new_precinct = Precinct.new(:display_name => "New Precinct")
      @objects = []
      @objects << new_precinct
      
      assert_equal new_precinct, @objects[0]
      
      new_precinct.before_validation
      assert new_precinct.ident
      
      # Find object by ident
      assert_equal new_precinct, @objects.find{|obj| obj.ident == new_precinct.ident}
    end
  end
  
  context "two yaml audit objects, one with errors" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/ballot_config.yml")
      @audit = TTV::YAMLAudit.new(@file, "ballot_config")
      
      @alerty_file = File.new("#{RAILS_ROOT}/test/elections/dirty_ballot_config.yml")
      @alerty_audit = TTV::YAMLAudit.new(@alerty_file, "ballot_config")
    end
    
    should "load YAML from file into array" do
      assert @audit.yml_election["audit_header"]
      assert @alerty_audit.yml_election["audit_header"]
    end
    
    should "detect as ballot config, record alert" do
      assert @audit.ballot_config?
      assert_equal false, @alerty_audit.ballot_config?
      
      assert @alerty_audit.alerts.find{|alert| alert.type == :not_ballot_config}
      assert_equal nil, @audit.alerts.find{|alert| alert.type == :not_ballot_config}
    end
    
    should "" do
      
    end
    
  end
  
end