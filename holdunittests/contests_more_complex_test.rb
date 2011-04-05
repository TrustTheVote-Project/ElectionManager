require "date"
# OSDV Election Manager - Unit Test for Contests - More complicated cases
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

# Construct some more complicated cases to check the detailed semantics of the data model and
# access methods.
class ContestMoreComplexTest < ActiveSupport::TestCase

  context "of Precincts and Splits" do
    setup do

# Setup a jurisdiction that will be the parent of everything in this test TODO: When Jurisdiction -> DistrictSet
      @juris = DistrictSet.new(:display_name => "Juris X")
      @juris.save!

      # create two Precincts with one PrecinctSplit containing 3 Districts, each (see code for 'setup_precinct' for that.)
      @prec1 = setup_precinct("PrecinctA", 1)
      @prec2 = setup_precinct("PrecinctB", 2)
      
      # Make the Districts so created be known as part of the Jurisdiction
      @juris.jur_districts << @prec1.precinct_splits[0].district_set.districts
      @juris.districts << @prec2.precinct_splits[0].district_set.districts
      
      # Make them part of the master Jurisdiction.
      @prec1.jurisdiction = @juris
      @prec2.jurisdiction = @juris
            
      @prec1.save!
      @prec2.save!
           
      # create two elections. Election 1, each part of @juris.
      @elect1 = Election.new(:display_name => "Election1", :district_set => @juris)
      @elect2 = Election.new(:display_name => "Election2", :district_set => @juris)      
      
    end
    
    
     should "should name" do
      assert true
    end
  end
end

  
  
