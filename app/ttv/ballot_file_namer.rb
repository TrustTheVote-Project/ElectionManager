# ballot_file_namer.rb: contruct file name for a ballot file
# Author: Pito Salas
# Date: Sept 28, 2010
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

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Brian Jordan, John Sebes, Jeffrey Gray
#
# Generate file names for Ballots. This allows us to have different schemes and let election officials decide what
# scheme they like.
#
# TODO: Remove this. Ballot File name strategies are implement using
# ruby Proc objects
# Ballot#filename and BallotRule::Base#ballot_filename.
class BallotFileNamer
  
  # Return a file name to use for the ballot corresponding to the parameters
  # <tt>precinct_split,precinct,election</tt>Parameters of the ballot
  # Return a string

  def ballot_file_name(precinct_split, election)
    remove_whitespace(precinct_split.precinct.display_name + "-" + precinct_split.display_name)
  end
  
  def remove_whitespace a_string
    a_string.gsub(" ", "-")
  end
  
  def to_s
    "Default Ballot File Namer"
  end
end
