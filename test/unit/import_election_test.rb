# OSDV Election Manager - Unit Test
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
