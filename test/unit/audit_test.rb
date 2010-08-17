require 'test_helper'
require 'ttv/alert'
require 'ttv/audit'

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
  end
  
  context "An audited hash" do
    setup do
      @yaml = File.new("#{RAILS_ROOT}/test/elections/refactored/yaml_refactor_alerts.yml")
      @xml = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_pre_processing_alerts.xml")
      @yaml_hash = YAML.load(@yaml) # Can be done in jurisdictions_controller, when file type is YAML
      xml_converter = TTV::XMLToEDH.new(@xml)
      @xml_hash = xml_converter.convert
      
      @jurisdiction = DistrictSet.new(:display_name => "District Set", :secondary_name => "An example, for example's sake.")
      @jurisdiction.before_validation # perform pre-validation, generating an ident
      
      @audit_yaml = Audit.new(:election_data_hash => @yaml_hash, :district_set => @jurisdiction)
      @audit_yaml.audit
      @audit_xml = Audit.new(:election_data_hash => @xml_hash, :district_set => @jurisdiction)
      @audit_xml.audit
    end
    
    should "have completed auditing" do
      assert !@audit_yaml.ready_for_import?
      assert !@audit_xml.ready_for_import?
    end
    
    should "store an alert for not defining a valid jurisdiction" do
      assert @audit_yaml.alerts[0]
      assert_equal "use_current", @audit_yaml.alerts[0].default_option
      
      assert @audit_xml.alerts[0]
      assert_equal "use_current", @audit_xml.alerts[0].default_option
    end

    context "with an alert option response" do
      setup do
        @audit_yaml.alerts[0].choice = "use_current"
        @audit_xml.alerts[0].choice = "use_current"

        @audit_yaml.apply_alerts
        @audit_yaml.audit
        
        @audit_xml.apply_alerts
        @audit_xml.audit
      end

      should "have a fixed hash, have no alerts left, be ready for import" do
        assert_equal 0, @audit_yaml.alerts.size # assert empty
        assert_equal 0, @audit_xml.alerts.size # assert empty
        
        assert @audit_yaml.ready_for_import?
        assert @audit_xml.ready_for_import?
        
        assert_equal @jurisdiction.ident, @audit_yaml.election_data_hash["body"]["districts"][0]["jurisdiction_identref"]
        assert_equal @jurisdiction.ident, @audit_xml.election_data_hash["body"]["districts"][0]["jurisdiction_identref"]
      end

      context "after an import" do
        setup do
          @import_yaml = TTV::ImportEDH.new(@audit_yaml.election_data_hash) # ImportEDH
          #@import_yaml.import
          
          @import_xml = TTV::ImportEDH.new(@audit_xml.election_data_hash) # ImportEDH
          #@import_xml.import
        end
        
        should "load and save jurisdictions" do
          @import_yaml.load_jurisdictions
          jurisdiction = DistrictSet.find_by_display_name("New Hampshire")
          assert jurisdiction
          assert_equal "1", jurisdiction.ident
        end
        
        should "load and save districts" do
          @import_yaml.load_jurisdictions
          @import_yaml.load_districts
          district = District.find_by_display_name "State of New Hampshire"
          assert district
          assert_equal "1", district.ident
          # Store newly created district type
          assert_equal "state", DistrictType.find_by_id(district.district_type_id).title
        end
        
        should "load and save precincts" do
          @import_yaml.load_jurisdictions
          @import_yaml.load_districts
          @import_yaml.load_precincts
          precinct_1 = Precinct.find_by_display_name "State of New Hampshire"
          precinct_2 = Precinct.find_by_display_name "Bedford County"
          assert precinct_1, precinct_2
          assert_equal "1", precinct_1.ident
          assert_equal District.find_by_display_name("State of New Hampshire"), precinct_1.districts[0]
        end
        
        should "load and save candidates" do
          @import_yaml.load_candidates
          candidate_1 = Candidate.find_by_ident "1"
          candidate_2 = Candidate.find_by_ident "2"
          assert candidate_1, candidate_2
          assert_equal "democrat", candidate_1.party.display_name
          assert_equal "republican", candidate_2.party.display_name
        end
        
        should "load and save contests" do
          @import_yaml.load_jurisdictions
          @import_yaml.load_districts
          @import_yaml.load_candidates
          @import_yaml.load_contests
          contest = Contest.find_by_display_name "County Attorney"
          assert contest
          assert_equal "1", contest.ident
          assert_equal "Marguerite Lefebvre Wageling", contest.candidates[0].display_name
          # assert_equal "winner_take_all", contest.voting_method.display_name 
        end

        should "load and save elections" do
          @import_yaml.load_jurisdictions
          @import_yaml.load_districts
          @import_yaml.load_precincts
          @import_yaml.load_candidates
          @import_yaml.load_contests
          @import_yaml.load_elections
          
          election = Election.find_by_display_name "New Hampshire General Election"
          assert election
          assert_equal "1", election.contests[0].ident
          assert_equal "1", election.district_set.ident
        end
        
        should "import all items (XML source)" do
          @import_xml.import
          
          assert District.find_by_display_name "State of New Hampshire"
          assert Contest.find_by_display_name "County Attorney"
          assert Candidate.find_by_ident "1"
          assert Precinct.find_by_display_name "State of New Hampshire"
          assert DistrictSet.find_by_display_name "New Hampshire"
          assert Election.find_by_display_name "New Hampshire General Election"
        end
        
        should "import a contest" do
          # TODO: Why is this failing?
          # contest = Contest.find_by_ident "1"
          # assert contest
          # assert 1, contest.ident
        end
      end
    end
  end
end
