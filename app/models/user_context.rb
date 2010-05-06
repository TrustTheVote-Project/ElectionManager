#
# Represent a place in the navigation of the application in a structured way. There is exactly one instance
# of this class and (for now) it is carried around in session[:current_context]. See current_context method in
# ApplicationController where it is created and returned to any other method that needs it.

class UserContext
  
  attr_accessor :jurisdiction, :election, :contest, :question, :precinct
  
  # Make sure we start with context at the root
  def initialize
    @jurisdiction = nil
    @election = nil
  end
  
  # Is there a Jurisdiction?
  def jurisdiction?
    !@jurisdiction.nil?
  end
  
  # Is there an Election?
  def election?
    !@election.nil?
  end
  
  # Is there a contst?
  def contest?
    !@contest.nil?
  end
  
  # Is there a question?
  def question?
    !@question.nil?
  end
  
  def precinct?
    !@precinct.nil?
  end

  # set state when choosing a contest
  def contest= a_contest
    @contest, @question, @precinct = a_contest, nil, nil
  end
  
  # set state when choosing a question
  def question= a_question
    @contest, @question, @precinct = nil, a_question, nil
  end
  
  # set state when choosing a precinct. A precinct always corresponds to a jurisdiction
  def precinct= a_prec
    @contest, @question, @precinct = nil, nil, a_prec
    @jurisdiction = a_prec.district_sets[0]
  end

  # set state when choosing an election. We automatically pick up the corresponding jurisdiction
  def election= an_election
    @election = an_election
    @contest, @question, @precinct = nil, nil, nil
    @jurisdiction = an_election.district_set unless an_election.nil?
  end
  
  # What is the name of the Jurisdiction, if any? 
  def jurisdiction_name
    if @jurisdiction
      @jurisdiction.display_name
    else
      "no jurisdiction selected"
    end
  end
  
  def reset
    @jurisdiction, @election, @contest, @question, @precinct = nil
  end
  
  # What is the secondary name of the Jurisdiction, if any?
  def jurisdiction_secondary_name
    second_name = @jurisdiction && @jurisdiction.secondary_name
    if second_name.nil?
      second_name = ""
    end
    second_name
  end
  
  # Convert to text
  def to_s
    s = ""
    if !@jurisdiction.nil?
      s << @jurisdiction.display_name
    end
    if !@election.nil?
      s << " > " + @election.display_name
    end
    if !@question.nil?
      s << " > " + @question.display_name
    end
    if !@contest.nil?
      s << " > " + @contest.display_name
    end
    if !@precinct.nil?
      s << " > " + @precinct.display_name
    end
    s
  end
end
