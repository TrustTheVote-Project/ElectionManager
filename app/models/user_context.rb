#
# Represent a place in the navigation of the application in a structured way. There is exactly one instance
# of this class and (for now) it is carried around in session[:current_context]. See current_context method in
# ApplicationController where it is created and returned to any other method that needs it.

class UserContext
  attr_accessor :jurisdiction, :election, :contest, :question, :precinct
  
  def initialize(session)
    @session = session
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
    !jurisdiction.nil?
  end

  def election?
    !election.nil?
  end

  def contest?
    !contest.nil?
  end
  
  def question?
    !question.nil?
  end
  
  def precinct?
    !precinct.nil?
  end

  def contest= a_contest
    @question, @precinct = nil, nil
    @session[:question_id], @session[:precinct_id] = nil, nil
    
    @session[:contest_id] = a_contest ? a_contest.id : nil
    @contest = a_contest
  end
  
  def question= a_question
    @contest, @precinct = nil, nil
    @session[:contest_id], @session[:precinct_id] = nil, nil
    
    @session[:question_id] = a_question ? a_question.id : nil
    @question= a_question
  end  

  def precinct= a_precinct
    @contest, @question = nil, nil
    @session[:contest_id], @session[:question_id] = nil, nil
    
    @session[:precinct_id] = a_precinct ? a_precinct.id : nil
    self.jurisdiction = a_precinct.district_sets[0]
    @precinct= a_precinct
  end
  
  def election= an_election
    contest, question, precint  = nil, nil, nil
    @session[:contest_id], @session[:question_id], @session[:precint_id]  = nil, nil, nil    
    
    @session[:election_id] = an_election ? an_election.id : nil
    self.jurisdiction = an_election.district_set unless an_election.nil?
    @election = an_election
  end

  def jurisdiction= a_jurisdiction
    @session[:jurisdiction_id] = a_jurisdiction ? a_jurisdiction.id : nil
    @jurisdiction = a_jurisdiction
  end
  
  def jurisdiction_name
    jurisdiction ? jurisdiction.display_name :  "no jurisdiction selected"
  end
  
  def reset
    @session[:election_id] = @session[:jurisdiction_id] = @session[:contest] = @session[:question] = @session[:precinct]= nil
    @election = @jurisdiction = @contest = @question = @precinct= nil
  end
  
  def jurisdiction_secondary_name
    second_name = (jurisdiction ? jurisdiction.secondary_name :  nil)
    second_name || ""
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
