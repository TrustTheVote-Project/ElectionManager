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

class ExportTest < ActiveSupport::TestCase
  context "An imported YAML/XML file" do
    setup do
      # Generate EDHs
      @yaml = File.new("#{RAILS_ROOT}/test/elections/refactored/yaml_refactor.yml")
      @yaml_hash = YAML.load(@yaml)
      
      @xml = File.new("#{RAILS_ROOT}/test/elections/refactored/xml_pre_processing.xml")
      xml_converter = TTV::XMLToEDH.new(@xml)
      @xml_hash = xml_converter.convert
      
      # Do imports
      import_yaml = TTV::ImportEDH.new(@yaml_hash)
      import_yaml.import
          
      import_xml = TTV::ImportEDH.new(@xml_hash) # ImportEDH
      import_xml.import
    end
    
    
    should "have imported correctly" do
      precinct = Precinct.find_by_display_name "Bedford County"
      district = District.find_by_display_name "State of New Hampshire"
      jurisdiction = DistrictSet.find_by_display_name "New Hampshire"
      assert precinct
      assert district
      assert_equal district, precinct.districts[0]
      assert_equal jurisdiction.display_name, district.district_sets[0].display_name
    end
    
    context "having exported YAML and XML" do
      setup do
        jurisdiction = DistrictSet.find_by_display_name("New Hampshire")
        @exporter = TTV::Export.new
        @yaml_export = @exporter.export_jurisdiction(jurisdiction, :yaml)
        #@yaml_exported_hash = YAML.load(@yaml_export)

        @xml = @exporter.export_jurisdiction(jurisdiction, :xml)
        
        xml_converter = TTV::XMLToEDH.new(@xml)
        @xml_export = xml_converter.convert # Convert to hash
      end
      
      should "export YAML, XML" do
        assert @yaml_export
        assert @xml_export
      end
      
      should "export specified jurisdiction" do
        assert_equal 1, @yaml_export['body']['jurisdictions'].size
        assert_equal "New Hampshire", @yaml_export['body']['jurisdictions'][0]['display_name']
        assert_equal "1", @yaml_export['body']['jurisdictions'][0]['ident']
        
        assert_equal 1, @xml_export['body']['jurisdictions'].size
        assert_equal "New Hampshire", @xml_export['body']['jurisdictions'][0]['display_name']
        assert_equal "1", @xml_export['body']['jurisdictions'][0]['ident']
      end
      
      should "export districts" do
        assert_equal "State of New Hampshire", @yaml_export['body']['districts'][0]['display_name']
        assert_equal "1", @yaml_export['body']['districts'][0]['ident']
        assert_equal "1", @yaml_export['body']['districts'][0]['jurisdictions'][0]['identref']

        assert_equal "State of New Hampshire", @xml_export['body']['districts'][0]['display_name']
        assert_equal "1", @xml_export['body']['districts'][0]['ident']
        assert_equal "1", @xml_export['body']['districts'][0]['jurisdictions'][0]['identref']
      end
      
      should "export precincts" do
        precinct_1 = @yaml_export['body']['precincts'].detect{|precinct| precinct['ident'] == "1"}
        assert_equal "State of New Hampshire", precinct_1['display_name']
        
        precinct_1 = @xml_export['body']['precincts'].detect{|precinct| precinct['ident'] == "1"}
        assert_equal "State of New Hampshire", precinct_1['display_name']
      end
      
      should "export elections" do
        assert_equal "New Hampshire General Election", @yaml_export['body']['elections'][0]['display_name']
        assert_equal "1", @yaml_export['body']['elections'][0]['ident']
        assert @yaml_export['body']['elections'][0]['start_date']
        assert_equal "1", @yaml_export['body']['elections'][0]['contests'][0]['identref']
        assert_equal "1", @yaml_export['body']['elections'][0]['jurisdiction_identref']
        
        assert_equal "New Hampshire General Election", @xml_export['body']['elections'][0]['display_name']
        assert_equal "1", @xml_export['body']['elections'][0]['ident']
        assert @xml_export['body']['elections'][0]['start_date']
        assert_equal "1", @xml_export['body']['elections'][0]['contests'][0]['identref']
        assert_equal "1", @xml_export['body']['elections'][0]['jurisdiction_identref']
      end
      
      should "export contests" do
        assert_equal "County Attorney", @yaml_export['body']['contests'][0]['display_name']
        assert_equal "1", @yaml_export['body']['contests'][0]['ident']
        assert_equal "Winner Take All", @yaml_export['body']['contests'][0]['voting_method']
        assert @yaml_export['body']['contests'][0]['candidates'].find {|candidate| candidate['identref'] == "1" }
        assert @yaml_export['body']['contests'][0]['candidates'].find {|candidate| candidate['identref'] == "2" }
        assert_equal "1", @yaml_export['body']['contests'][0]['district_identref']
        
        assert_equal "County Attorney", @xml_export['body']['contests'][0]['display_name']
        assert_equal "1", @xml_export['body']['contests'][0]['ident']
        assert_equal "Winner Take All", @xml_export['body']['contests'][0]['voting_method']
        assert @xml_export['body']['contests'][0]['candidates'].find {|candidate| candidate['identref'] == "1" }
        assert @xml_export['body']['contests'][0]['candidates'].find {|candidate| candidate['identref'] == "2" }
        assert_equal "1", @xml_export['body']['contests'][0]['district_identref']
      end
      
      should "export candidates" do
        candidate_1 = @xml_export['body']['candidates'].find { |candidate| candidate['ident'] == "1"}
        assert candidate_1
        assert_equal "1", candidate_1['ident']
        assert_equal "Marguerite Lefebvre Wageling", candidate_1['display_name']
        assert_equal "democrat", candidate_1['party']
        
        candidate_2 = @xml_export['body']['candidates'].find { |candidate| candidate['ident'] == "2"}
        assert candidate_2
        assert_equal "2", candidate_2['ident']
        assert_equal "Marguerite Lefebvre Wageling", candidate_2['display_name']
        assert_equal "republican", candidate_2['party']
        
        candidate_1 = @yaml_export['body']['candidates'].find { |candidate| candidate['ident'] == "1"}
        assert candidate_1
        assert_equal "1", candidate_1['ident']
        assert_equal "Marguerite Lefebvre Wageling", candidate_1['display_name']
        assert_equal "democrat", candidate_1['party']
        
        candidate_2 = @yaml_export['body']['candidates'].find { |candidate| candidate['ident'] == "2"}
        assert candidate_2
        assert_equal "2", candidate_2['ident']
        assert_equal "Marguerite Lefebvre Wageling", candidate_2['display_name']
        assert_equal "republican", candidate_2['party']
      end
    end
  end
end

