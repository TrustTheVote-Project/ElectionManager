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

class VotingMethodTest < ActiveSupport::TestCase
 
  def test_dbLoaded
    assert_not_nil VotingMethod.find(1), "VotingMethods have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=test"
  end

  def test_xml_representation
    VotingMethod.find(:all).each do |dt|
      assert_equal(VotingMethod.xmlToId(dt.idToXml), dt.id, "VotingMethod xml representations")
    end
  end

end
