require 'test_helper'
require 'ttv/alert'
require 'ttv/audit'

class AuditTest < ActiveSupport::TestCase
  
  context "An audit object" do
    setup do
      @hash = {:a => 2, :b => 3, :c => 4}
      @alert = Alert.new({:message => "No jurisdiction name specified.", :alert_type => :no_jurisdiction, :options => 
            {:use_current => "Use current jurisdiction test", :abort => "Abort import"}, :default_option => :use_current})
    end
    
    should "be instantiated with a hash" do
      audit_obj = Audit.new(:election_data_hash => @hash)
    end
    
    should "associate with an alert" do
      audit_obj = Audit.new(:election_data_hash => @hash)
      audit_obj.alerts << @alert
    end
    
    
    
  end
  
  context "An audited hash" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/refactored/simple_yaml.yml")
      @hash_to_audit = YAML.load(@file) # Can be done in jurisdictions_controller, when file type is YAML
      @jurisdiction = DistrictSet.new(:display_name => "District Set", :secondary_name => "An example, for example's sake.")
      @audit_obj = Audit.new(:election_data_hash => @hash_to_audit, :district_set => @jurisdiction)
      @audit_obj.audit
    end
    
    should "not be changed" do
      assert_equal @hash_to_audit, @audit_obj.election_data_hash
    end
    
    should "store an alert for not defining a valid jurisdiction" do
      assert @audit_obj.alerts[0]
      assert_equal "use_current", @audit_obj.alerts[0].default_option
    end
    
    context "with an alert option response" do
      setup do
        @audit_obj.alerts[0].choice = "use_current"
        @audit_obj.apply_alerts
        @audit_obj.audit
      end
      
      should "have a fixed hash, have no alerts left, be ready for import" do
        assert_equal 0, @audit_obj.alerts.size # assert empty

        assert_equal "District Set", @audit_obj.election_data_hash["ballot_info"]["jurisdiction_display_name"]
      end
      
      context "after an import" do
        setup do
          @import_obj = TTV::ImportEDH.new(@audit_obj.election_data_hash) # ImportEDH
          @import_obj.import
        end
        
        should "import a precinct with a district to a jurisdiction" do
          precinct = Precinct.find_by_display_name "The Only Precinct"
          district = District.find_by_display_name "The Only District"
          
          assert precinct, district
          
          assert_equal district, precinct.districts[0]
          
          assert_equal @jurisdiction.display_name, district.district_sets[0].display_name
        end
      end
      
    end
  end
end
