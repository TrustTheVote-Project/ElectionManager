require 'test_helper'
require 'ttv/alert'
require 'ttv/audit'

class AuditTest < ActiveSupport::TestCase
  context "An audited hash" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/simple_yaml.yml")
      @hash_to_audit = YAML.load(@file) # Can be done in jurisdictions_controller, when file type is YAML
      @jurisdiction = DistrictSet.new(:display_name => "District Set", :secondary_name => "An example, for example's sake.")
      @audit_obj = TTV::Audit.new(@hash_to_audit, [], @jurisdiction) # contexrt hash for third
      @audit_obj.audit
    end
    
    should "not be changed" do
      assert_equal @hash_to_audit, @audit_obj.hash # 2 run the audit, check that the alerts come out
    end
    
    should "throw an alert for not defining a valid jurisdiction" do
      assert @audit_obj.alerts[0]
      assert_equal :use_current, @audit_obj.alerts[0].default_option
    end
    
    context "with an alert option response" do
      setup do
        @audit_obj.alerts[0].choice = :use_current
        @audit_obj = TTV::Audit.new(@audit_obj.hash, @audit_obj.alerts, @jurisdiction)
        @audit_obj.apply_alerts
        @audit_obj.audit
      end
      
      should "have a fixed hash, have no alerts left, be ready for import" do
        assert_equal 0, @audit_obj.alerts.size
        assert @audit_obj.ready_for_import

        assert_equal "District Set", @audit_obj.hash["ballot_info"]["jurisdiction_display_name"]
      end
      
      context "after an import" do
        setup do
          @import_obj = TTV::HashImport.new(@audit_obj.hash)
          @import_obj.import
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