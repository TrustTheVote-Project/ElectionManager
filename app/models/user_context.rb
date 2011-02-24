# OSDV Election Manager - UserContext Model
# Author: Pito Salas
# Date: 10/27/2010
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


# Represent a place in the navigation of the application in a structured way. There is exactly one instance
# of this class and (for now) it is carried around in session[:current_context]. See current_context method in
# ApplicationController where it is created and returned to any other method that needs it.

class UserContext
  attr_accessor :what, :jurisdiction, :election, :contest, :question, :precinct
  
  def initialize(session)
    @session = session
    @session[:what] ||= :nothing
  end
  
# Validate the "what" legal values - primary selected object's 'class'
  def valid_what_value? what_value
    if ![:jurisdiction, :contest, :question, :election, :precinct, :district, :split, :district_set, :nothing].include?(what_value)
      raise "Invalid User Context Session Status: #{what_value}"
    end
    true
  end

# Return the primary selected object's 'class'
  def what
    valid_what_value? @session[:what]
    @session[:what]
  end

# And assign it
  def what= new_context_state
    valid_what_value? new_context_state
    @session[:what] = new_context_state
  end

#TODO: DRY these common methods with define_method
  def jurisdiction
    @jurisdiction || @session[:jurisdiction_id] && @jurisdiction = DistrictSet.find(@session[:jurisdiction_id])
  end
  
  def election
    @election || @session[:election_id] && @election = Election.find(@session[:election_id])
  end
  
  def contest
    @contest || @session[:contest_id] && @contest = Contest.find(@session[:contest_id])
  end

  def question
    @question || @session[:question_id] && @question = Question.find(@session[:question_id])
  end  
  
  def precinct
    @precinct || @session[:precinct_id] && @precinct = Precinct.find(@session[:precinct_id])
  end  

  def jurisdiction?
    !self.jurisdiction.nil?
  end

  def election?
    !self.election.nil?
  end

  def contest?
    !self.contest.nil?
  end
  
  def question?
    !self.question.nil?
  end
  
  def precinct?
    !self.precinct.nil?
  end

# Set the top level selected object's 'class' and identity.
  def contest= a_contest
    raise "Invalid contest setting in user_context.rb" if a_contest.nil?
    self.what = :contest
    @session[:contest_id] = a_contest.id
    @session[:election_id] = Contest.find(a_contest).election.id
  end
  
  def question= a_question
    raise "Invalid question setting in user_context.rb" if a_question.nil?
    self.what = :question
    @session[:question_id] = a_question ? a_question.id : nil
  end  

  def precinct= a_precinct
    raise "Invalid precinct setting in user_context.rb" if a_precinct.nil?
    self.what = :precinct
    @session[:precinct_id] = a_precinct ? a_precinct.id : nil
  end
  
  def election= an_election
    raise "Invalid election setting in user_context.rb" if an_election.nil?
    self.what = :election
    @session[:election_id] = an_election ? an_election.id : nil
  end

  def jurisdiction= a_jurisdiction
    raise "Invalid jurisdiction setting in user_context.rb" if a_jurisdiction.nil?
    self.what = :jurisdiction
    @session[:jurisdiction_id] = a_jurisdiction ? a_jurisdiction.id : nil
  end
  
  def jurisdiction_name
    self.jurisdiction ? jurisdiction.display_name :  "no jurisdiction selected"
  end
  
  def reset
    self.what = :nothing
    @session[:election_id] = @session[:jurisdiction_id] = @session[:contest_id] = @session[:question_id] = @session[:precinct_id] = nil
    @election = @jurisdiction = @contest = @question = @precinct = nil
  end
  
  def jurisdiction_secondary_name
    second_name = (jurisdiction ? jurisdiction.secondary_name :  nil)
    second_name || ""
  end

  # Convert to text
  def to_s
    s = 
    if !@jurisdiction.nil?
      s << "Jur:" + @jurisdiction.display_name
    end
    if !@election.nil?
      s << " > Elec:" + @election.display_name
    end
    if !@question.nil?
      s << " > Ques:" + @question.display_name
    end
    if !@contest.nil?
      s << " > Cont:" + @contest.display_name
    end
    if !@precinct.nil?
      s << " > Prec:" + @precinct.display_name
    end
    return s
  end
end
