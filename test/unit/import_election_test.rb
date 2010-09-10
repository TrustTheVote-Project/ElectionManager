require 'test_helper'
require 'ap'

class ImportElectionTest < ActiveSupport::TestCase
  
  context "Election Info File" do
    setup do
# Need context of districts into which to import election
      @juris = DistrictSet.create!(:display_name => "Jurisdiction Madeup")
      @juris_yml = File.new("#{RAILS_ROOT}/test/unit/data/import_election_edh/madeup-medium-juris.yml")
      @juris_yml_hash = YAML.load(@juris_yml)
      @juris_import = TTV::ImportEDH.new("jurisdiction_info", @juris_yml_hash)
      @juris_import.import @juris
      
      @yaml = File.new("#{RAILS_ROOT}/test/unit/data/import_election_edh/madeup-medium-election.yml")
      @yaml_hash = YAML.load(@yaml)               # @TODO Can be done in jurisdictions_controller, when file type is YAML
      @audit = Audit.new(:content_type => "election_info", :election_data_hash => @yaml_hash, :district_set => @juris)
      @import = TTV::ImportEDH.new("election_info", @audit.election_data_hash)
    end
    
    should "show the right info" do
      ds = DistrictSet.find_by_display_name("Jurisdiction Madeup")
      assert_equal ds, @juris
      @import.import @juris
      assert 1, @juris.elections.length
      elections = @juris.elections[0]
      assert 2, elections.contests.length
    end
  end
  
end
