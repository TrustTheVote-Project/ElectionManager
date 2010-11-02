require "date"
# OSDV Election Manager - Unit Test for @TODO
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

require 'test_helper'
require 'ap'

class ViewBuilderHelperTest < ActionView::TestCase
  context "View Builder" do
    should "generate headers" do
      assert_equal '<tr><th>Hello</th><th>Display Name</th><th class="last">&nbsp</th></tr>', ttv_view_list_hdr(["hello", "display_name"])
    end
    
    should "generate a row" do
      a = ttv_view_list_rows(Asset.make(:display_name=>"Hello"), ["display_name"])
      assert a
    end
    
    should "generate a correct link" do
      assert_equal '<a href="/assets/1">Show</a>', ttv_view_link_to(:show, Asset.make(:display_name=>"Hello"))
    end
    
    should "generate a whole list view" do
      coll = [Asset.make(:display_name => "one"), Asset.make(:display_name => "two")]
      assert ttv_view_list_body coll, ["display_name"]
    end
    
    should "generate a field for a show" do
      assert ttv_show_field(Asset.make(:display_name => "one"), "asset")
    end
  end
end

  
  