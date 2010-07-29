require 'test_helper'
require 'ttv/alert'
require 'ttv/audit'

class AuditTest < ActiveSupport::TestCase
  context "An audited hash" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/simple_yaml.yml")
      @hash_to_audit = YAML.load(@file) # Can be done in jurisdictions_controller, when file type is YAML
      @jurisdiction = DistrictSet.new(:display_name => "District Set", :secondary_name => "An example, for example's sake.")
      audit_obj = TTV::Audit.new(@hash_to_audit, [], @jurisdiction) # contexrt hash for third 
      @hash = audit_obj.hash
      @alerts = audit_obj.alerts
    end
    
    should "not be changed" do
      assert_equal @hash_to_audit, @hash # 2 run the audit, check that the alerts come out
    end
    
    should "throw an alert for not defining a valid jurisdiction" do
      assert @alerts[0]
      assert_equal :use_current, @alerts[0].default_option
    end
    
    context "with an alert option response" do
      setup do
        @alerts[0].choice = :use_current
        audit_obj = TTV::Audit.new(@hash, @alerts, @jurisdiction)
        @changed_hash = audit_obj.hash
        @processed_alerts = audit_obj.alerts
        @ready_for_import = audit_obj.ready_for_import
      end
      
      should "have a fixed hash, have no alerts left, be ready for import" do
        assert @ready_for_import
        assert_equal 0, @processed_alerts.size
        assert_equal "District Set", @changed_hash["ballot_info"]["jurisdiction_display_name"]
      end
      
      context "after an import" do
        setup do
          import_obj = TTV::HashImport.new(@changed_hash)
        end
        
        should "import a precinct with a district to a jurisdiction" do
          precinct = Precinct.find_by_display_name "The Only Precinct"
          district = District.find_by_display_name "The Only District"
          
          assert precinct, district
          
          assert_equal precinct.districts[0], district
          
          assert_equal district.district_sets[0].display_name, @jurisdiction.display_name
        end
      end
      
    end
  end
end