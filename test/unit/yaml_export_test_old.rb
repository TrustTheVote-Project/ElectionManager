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


class YAMLExportTest < ActiveSupport::TestCase
  
  def imp_exp path
    import_obj = TTV::YAMLImport.new(File.new(path))
    @imp_object = import_obj.import
    @export_obj = TTV::YAMLExport.new(@imp_object)

  end
  
  context "import tiny.yml and try to export it back" do
    setup do
      imp_exp("#{RAILS_ROOT}/test/elections/tiny.yml")
    end
    
    should "export tiny correctly and safely" do
      @export_obj.do_export
      res_hash = @export_obj.election_hash
      assert res_hash["ballot_info"]
      assert_equal "One Contest Election", res_hash["ballot_info"]["display_name"]
      assert_equal 1, res_hash["ballot_info"]["precinct_list"].length
      assert_equal "City of Random", res_hash["ballot_info"]["precinct_list"][0]["district_list"][0]["display_name"]
      assert_equal "Democrat", res_hash["ballot_info"]["contest_list"][0]["candidates"][0]["party_display_name"]
    end
    
    context "also import generated.yml and try to export it back" do
      setup do
        imp_exp("#{RAILS_ROOT}/test/elections/generated.yml")
      end
      
      should "export generated.yml back correctly too" do
        @export_obj.do_export
        res_hash = @export_obj.election_hash
      end
    end
  end
  
  context "import 101.26.yml and try to export it back" do
    setup do
      imp_exp("test/elections/xml/101.26.yml")
    end
  
    should "export 101.26.yml correctly and safely" do
      @export_obj.do_export
      res_hash = @export_obj.election_hash
      assert res_hash["ballot_info"]
      assert res_hash["ballot_info"]["question_list"]
      assert_equal "State Initiative Measure 1033", res_hash["ballot_info"]["question_list"][0]["display_name"]
      assert_equal  "Initiative Measure No. 1033 concerns state, county and city revenue. | |This measure would limit growth of certain state, county and city revenue to annual inflation and population growth, not including voter-approved revenue increases. Revenue collected above the limit would reduce property tax levies.  | |Should this measure be enacted into law? Yes [ ] No [ ]",
                    res_hash["ballot_info"]["question_list"][0]["question"]
    end
  end
end

