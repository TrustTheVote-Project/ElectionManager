require 'test_helper'
# require 'ttv/alert'

class YAMLCollectTest < ActiveSupport::TestCase
  context "given a yaml file" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/ballot_config.yml")
      @collect = TTV::YAMLCollect.new(@file)
      
      @collect.collect
    end
    
    should "load YAML from file into array" do
      assert @collect.yaml_election["audit_header"]
    end
    
    should "store type" do
      assert_equal "ballot_config", @collect.object_hash[:type]
    end
    
    should "store contests" do
      assert @collect.object_hash[:contests]
      
      # display name
      contest = @collect.object_hash[:contests].find{|cont| cont[:display_name] == "President and Vice-President of the United States"}
      assert contest
      
      # order
      assert_equal 0, contest[:order]
      assert contest[:candidates]
      
      assert contest[:candidates][0]
      
      # candidate
        # ident
      assert @collect.object_hash[:candidates].find{|cand| cand[:ident] == contest[:candidates][0][:ident]}

        # display_name
      candidate = @collect.object_hash[:candidates].find{|cand| cand[:display_name] == "George Phillies and Christopher Bennett"}
        # order
      contest_candidate_ident = contest[:candidates].find{|cand| cand[:order] == 3}[:ident]
      assert_equal candidate[:ident], contest_candidate_ident
      
        # party_ident
          # display_name
        # district
        # voting method      
    end
  end
end