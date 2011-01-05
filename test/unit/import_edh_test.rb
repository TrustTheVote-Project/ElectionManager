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

class ImportEDHTest < ActiveSupport::TestCase
  
  context "tiny_case.yml" do
    setup do
      @yaml = File.new("#{RAILS_ROOT}/test/unit/data/import_edh/tiny_case.yml")
      @yaml_hash = YAML.load(@yaml)               # Can be done in jurisdictions_controller, when file type is YAML
      @juris = DistrictSet.create!(:display_name => "Jurisdiction tiny_case")
      @audit = Audit.new(:content_type => "jurisdiction_info", :election_data_hash => @yaml_hash, :district_set => @juris)
    end

    context "imported" do
      setup do
        @audit.audit 
        @import = TTV::ImportEDH.new("jurisdiction_info", @audit.election_data_hash)
        @jur = DistrictSet.find_by_display_name("Jurisdiction tiny_case")
        @import.import @jur
      end
      
      should "show one precinct in the jurisdiction" do
        assert_equal 1, @jur.precincts.count
      end
      
      should "create 1 valid precinct" do
        a = Precinct.find_by_display_name("PRECINCT 1")
        assert_valid a
      end
      should "create a precinct with the expected name" do
        a = Precinct.find_by_display_name("PRECINCT 1")
        assert_equal "PRECINCT 1", a.display_name
      end
      should "create a precinct with the correct jurisdiction" do
        a = Precinct.find_by_display_name("PRECINCT 1")
        assert_equal @jur, a.jurisdiction
      end
      
      should "create a precinct with the correct jurisdiction id" do
        a = Precinct.find_by_display_name("PRECINCT 1")
        assert_equal @jur.id, a.jurisdiction.id
      end
      
      should "create 1 precinct split" do
        prec = Precinct.find_by_display_name("PRECINCT 1")
        assert_equal 1, prec.precinct_splits.count
      end
      
      should "have correclty named split" do
        prec = Precinct.find_by_display_name("PRECINCT 1")
        splits = prec.precinct_splits
        split = splits[0]
        assert_equal "702 - MIDWAY-0000", split.display_name
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
      
      should "have districts of the right type" do
        prec = Precinct.find_by_display_name("PRECINCT 1")
        split = prec.precinct_splits[0]
        dset = split.district_set
        dset.districts.each { |dist| assert_equal "WARD", dist.district_type.title }        

      end
    end
  end
end
