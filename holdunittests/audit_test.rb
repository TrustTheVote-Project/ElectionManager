# OSDV Election Manager - Unit Test for @TODO
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require File.dirname(__FILE__) + '/../test_helper'

class AuditTest < ActiveSupport::TestCase
  
  context "An audit object" do
    setup do
      @hash = {:a => 2, :b => 3, :c => 4}
      @alert = Alert.new({:message => "No jurisdiction name specified.", :alert_type => "no_jurisdiction", :options => 
            {"use_current" => "Use current jurisdiction test", "abort" => "Abort import"}, :default_option => "use_current"})
    end
    
    should "be instantiated with a hash" do
      audit_obj = Audit.new(:election_data_hash => @hash)
    end
    
    should "associate with an alert" do
      audit_obj = Audit.new(:election_data_hash => @hash)
      audit_obj.alerts << @alert
    end
    
    should "correctly search a simple hash" do
      audit_obj = Audit.new(:election_data_hash => @hash)
      t = [{:a => 1}, {:b => 2}, {:c=> 3}]
      assert audit_obj.input_has? t, :b, 2
      assert !audit_obj.input_has?(t, "c", 2)
    end
  end
  
  context "A test hash" do
    setup do
      @yaml = File.new("#{RAILS_ROOT}/test/unit/data/audit_test/yml_audit_test_data.yml")
      @xml = File.new("#{RAILS_ROOT}/test/unit/data/audit_test/xml_audit_test_data.xml")
      @yaml_hash = YAML.load(@yaml) # Can be done in jurisdictions_controller, when file type is YAML
      
# TODO: In addition to XMLToEDH we need a YMLToEDH (although the latter will do next to nothing!)
      xml_converter = TTV::XMLToEDH.new(@xml)
      @xml_hash = xml_converter.convert
      @jurisdiction = DistrictSet.new(:display_name => "District Set", :secondary_name => "An example, for example's sake.")
      @jurisdiction.before_validation # perform pre-validation, generating an ident
      
      @audit_yaml = Audit.new(:content_type => "jurisdiction_info", :election_data_hash => @yaml_hash, :district_set => @jurisdiction)
      @audit_xml = Audit.new(:content_type => "jurisdiction_info", :election_data_hash => @xml_hash, :district_set => @jurisdiction)
    end
    
    should "be successfully built from xml" do
      assert @audit_xml.audit
    end
    
    should "be successfully built from yml" do
      assert @audit_yaml.audit 
    end

    context "with an alert option response" do
      setup do
        @audit_yaml.audit
        @audit_yaml.alerts[0].choice = "generate"
        @audit_yaml.alerts[1].choice = "generate"

        @audit_xml.audit
  
        @audit_yaml.apply_alerts
        @audit_yaml.audit
        
        @audit_xml.apply_alerts
        @audit_xml.audit
      end

      should "have a fixed hash, have no alerts left, be ready for import" do
        assert_equal 2, @audit_yaml.alerts.size # two alerts
        assert_equal 0, @audit_xml.alerts.size # assert empty
        
        assert @audit_yaml.ready_for_import?
        assert @audit_xml.ready_for_import?
      end
    end
  end
end
