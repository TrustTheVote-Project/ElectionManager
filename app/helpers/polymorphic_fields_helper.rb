# OSDV Election Manager - Polymorphic Fields
# Author: TODO
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
#
# A set of methods to for consistent handling of information across many models. The idea is that 
# there is a set of unique (across the product) 'poly_name's that correspond to attributes of models. They
# are used in all kinds of places to construct views.

module PolymorphicFieldsHelper
  
  # Return the value for a certain polyname for a certain ActiveRecord element. In most cases the polyname corresponds to an attribute name, but
  # not always. If the name as used in a view, for a UI reason, is different from what the model uses, the translation may happen here. This
  # avoids cluttering the model with lots of view specific stuff.
  #  
  def poly_get_value(element, poly_name)
    case poly_name
    when "election"
      element.display_name
    when "contest"
      element.display_name
    when "district"
      element.display_name
    when "default_voting_method"
      VotingMethod.find(element.default_voting_method_id).display_name
    when "ballot_style_template"
       BallotStyleTemplate.find(element.ballot_style_template_id).display_name
    when "contests"
      element.contests.count
    when "questions"
      element.questions.count
    when "date"
      element.start_date.to_date.to_formatted_s(:long) 
    when "ballot"
      element.precinct_split.display_name
    when "n_contests"
      element.contests.size
    when "n_questions"
      element.contests.size
    when "n_candidates"
      element.candidates.size
    when "asset"
      element.asset.url(:medium)
    when "party_id"
      element.party_id.to_s
    when "contest_id"
      element.contest_id.to_s
    when "position"
      element.position.to_s
    when "contest"
      element.contest.display_name
    when "jurisdiction"
      DistrictSet.find_by_id(element.district_set_id).display_name
    else
      element.read_attribute(poly_name)
    end
  end
 
  # Return a suitable column header for a certain polyname. 
  def poly_name_column_header(poly_name)
    case poly_name
    when "n_contests"
      t("ttv.n_questions", :default => "contests")
    when "n_questions"
      t("ttv.n_questions", :default => "questions")
    when "n_candidates"
      t("ttv.n_candidates", :default => "candidates")
    else t("ttv."+poly_name, :default => poly_name.titleize)
    end
  end
  
end
