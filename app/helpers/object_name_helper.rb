# OSDV Election Manager - Object Name Helpers
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

# A set of utility helpers to take a class name and produce various kinds of text representations of the kind of object
module ObjectNameHelper
  
  # Convert a Model Class into a singular english word for it.
  def singular_name_for(clazz)
    clazz.to_s.downcase
  end
  
  # Convert a Model Class into a plural english word for it
  def plural_name_for(clazz)
    clazz.to_s.downcase.pluralize
  end
  
  # Specific phrases, here so we can translate them easily when the time comes.
  def object_not_defined_yet_message(clazz)
    "No #{plural_name_for(clazz)} defined yet"
  end
end