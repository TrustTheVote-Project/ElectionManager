require 'test_helper'
require 'ap'

class AuditTest < ActiveSupport::TestCase
  
  context "for data/import_edh/tiny_case.yml" do
    setup do
      @yaml = File.new("#{RAILS_ROOT}/test/unit/data/import_edh/tiny_case.yml")
      @yaml_hash = YAML.load(@yaml) # Can be done in jurisdictions_controller, when file type is YAML
      @juris = DistrictSet.create!(:display_name => "Jurisdiction tiny_case")
      @audit = Audit.new(:election_data_hash => @yaml_hash, :district_set => @juris)
    end
    
    should "gen a single alert when audited" do
      @audit.audit
      assert_equal 1, @audit.alerts.size
    end
    
    should "be fixable after auditing" do
      @audit.audit
      @audit.alerts[0].choice = "use_current"
      @audit.apply_alerts
      assert @audit.ready_for_import?
    end
    
    context ", fixed, imported, " do
      setup do
        @audit.audit
        @audit.alerts[0].choice = "use_current"
        @audit.apply_alerts
        @import = TTV::ImportEDH.new(@audit.election_data_hash)
        @jur = DistrictSet.find_by_display_name("Jurisdiction tiny_case")
        @import.import_to_jurisdiction @jur
      end
      
      should "show one precinct in the jurisdiction" do
        assert_equal 1, @jur.precincts.count
      end
      
      should "create 1 precinct" do
        Precinct.find_by_display_name("PRECINCT 1")
      end
      
      should "create 1 precinct split" do
        prec = Precinct.find_by_display_name("PRECINCT 1")
        assert_equal 1, prec.precinct_splits.count
      end
      
      should "contain the right district set" do
        prec = Precinct.find_by_display_name("PRECINCT 1")
        assert_equal 1, prec.precinct_splits.count
        split = prec.precinct_splits[0]
        assert_not_nil split.district_set
        assert_valid split.district_set
      end
      
      should "have districts in the right jurisdiction" do
        prec = Precinct.find_by_display_name("PRECINCT 1")
        split = prec.precinct_splits[0]
        dset = split.district_set
        dset.districts.each { |dist| assert_equal @jur, dist.jurisdiction }        
      end
    end
  end
end

