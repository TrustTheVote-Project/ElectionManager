# OSDV Election Manager - Shoulda Macros creating test data from templates
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
require "test/unit"
class Test::Unit::TestCase
  
# A new approach to generating our complicated test data. Use an array as a template containing the essential information
# only. This results in a more flexible, compact and self-documenting way of dynamically creating test fixtures. A nested array is
# the argument 'struct' and it supplies names and submodels for the being created. An example is easiest:
#
# setup_juris_structured with this input struct
#     struct = ["Jur", [["Prec1", ["Split1", ["Dist1", "Dist2"]]],
#                        ["Prec2", ["Split2", ["Dist3", "Dist4"]]]]]
#     @reslt = setup_juris_structured(struct)
#
# Will create a Jurisdiction "Jur" with two Precincts, "Prec1" and "Prec2". Each Precinct has one PrecinctSplit. "Prec1" has a PrecinctSplit with 2
# Districts, "Dist1" and "Dist2". "Prec2" has a PrecinctSplit with two more Districts, "Dist3" and "Dist4". The call to setup_juris_structured generates
# all the Precinct, PrecinctSplit, DistrictSet, and District instances required. They are all saved to the database. 
#
# Return value is a nested array with exactly the same structure, with all the strings (which were display_names) replaced by the corresponding model
# instance that was created.
#
#
# setup_juris_structured
#
# <tt>struct:</tt> A nested array defining the Jurisdiction. ["jurisdiction-display-name", [... list of precincts ...]]
# <tt>Returns:</tt> A nested array with the corresponding result model instances. [DistrictSet.instance, [ ... list of precinct info]]
#
  def setup_juris_structured(struct)
    assert struct.class == Array
    assert struct[0].class == String
    juris = DistrictSet.create(:display_name => struct[0])
    result_prec_list = []
    struct[1].each do
      |prec_struct| 
      result_precinct = setup_precinct_structured(prec_struct, juris)
      result_precinct[0].jurisdiction = juris
      result_prec_list << result_precinct 
    end
    return [juris, result_prec_list]
  end

# setup_precinct_structured
#
# <tt>struct:</tt> A nested array defining the Jurisdiction. ["jurisdiction-display-name", [... list of precincts ...]]
# <tt>juris:</tt> The Jurisdiction (== DistrictSet TODO) in which the Precinct will be created.
# <tt>Returns:</tt> A nested array with the corresponding result model instances. [Precinct.instance, [ ... list of PrecinctSplit info]]
#
#    struct = ["Prec1", [["PrecSplit1", ["dist1", "dist2"]],
#                      ["PrecSplit2", ["dist3", "dist4"]]]]
#   @precinct = setup_precinct_structured(struct, @jur)
  def setup_precinct_structured(struct, juris)
    assert struct.class == Array
    assert struct[0].class == String
    prec = Precinct.create(:display_name => struct[0])
    result_precinct_split_list = []
    struct[1].each do
      |split_struct| 
      result_prec_split = setup_precinct_split_structured(split_struct, juris)
      prec.precinct_splits << result_prec_split[0]
      result_precinct_split_list << result_prec_split
    end  
    return [prec, result_precinct_split_list]
  end
  
# setup_precinct_split_structured
#
# <tt>struct:</tt> A nested array defining the Jurisdiction. ["jurisdiction-display-name", [... list of precincts ...]]
# <tt>juris:</tt> The Jurisdiction (== DistrictSet TODO) in which the Precinct will be created
# <tt>Returns:</tt> A nested array with the corresponding result model instances. [PrecinctSplit.instance, [ ... list of District info]]
#
# struct = ["PrecSplit", ["distx", "disty"]]
# setup_precinct_slit_structured(struct, @juris)
#
  def setup_precinct_split_structured(struct, juris)
    assert struct.class == Array
    prec_split_name = struct[0]
    assert prec_split_name.class == String
    distset = DistrictSet.new(:display_name => prec_split_name+"(ds)")
    result_dist_list = []
    struct[1].each do
      |dist_name|
      result_district = setup_district_structured(dist_name, juris)
      distset.districts << result_district
      result_dist_list << result_district
    end
    psplit = PrecinctSplit.create(:display_name => prec_split_name)
    psplit.district_set = distset
    return [psplit, result_dist_list]    
  end

# setup_district_structured
#
# <tt>struct:</tt> A nested array defining the Jurisdiction. ["jurisdiction-display-name", [... list of precincts ...]]
# <tt>juris:</tt> The Jurisdiction (== DistrictSet TODO) in which the Precinct will be created
# <tt>Returns:</tt> A nested array with the corresponding result model instances. [District.instance, ... ]
#
# struct = ["PrecSplit", ["distx", "disty"]]
# setup_district_structured(struct, @juris)
#
# setup_district_structured("I am a district", @juris)
#
  def setup_district_structured(dist_name, juris)
    assert dist_name.class == String
    District.create(:display_name => dist_name, :jurisdiction => juris)
  end
end
