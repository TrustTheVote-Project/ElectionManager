#
# Represent a place in the navigation of the application in a structured way. There is exactly one instance
# of this class and (for now) it is carried around in session[:current_context]. See current_context method in
# ApplicationController where it is created and returned to any other method that needs it.

class UserContext
  
  attr_accessor :jurisdiction, :election, :contest, :question
  
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

  # choosing a contest always means that we don't have a question chosen
  def contest= new_contest
    @contest = new_contest
    @question = nil
  end
  
  # choosing a question always means that we don't have a contest chosen
  def question= new_question
    @question = new_question
    @contest = nil
  end
  
  # What is the name of the Jurisdiction, if any? 
  def jurisdiction_name
    if @jurisdiction
      @jurisdiction.display_name
    else
      "no jurisdiction selected"
    end
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
    if !question.nil?
      s << " > " + @question.display_name
    end
    if !@contest.nil?
      s << " > " + @contest.display_name
    end
    s
  end
end
