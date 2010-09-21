module PrecinctsHelper

# Return how many contests are defined for this precinct and election, 
# or the total number of contests if we are not looking at a specific election
  def precinct_contest_count_helper (prec, elect)
    if elect.nil? 
      "-tbd-"
    else
      Contest.contests_for_precinct_election(prec, elect).length
    end
  end
  
# Return how many questions are defined for this precinct and election, 
# or the total number of questions, if we are not looking at a specific election
  def precinct_question_count_helper (prec, elect)
    if elect.nil? 
      "-tbd-"
    else
      Question.questions_for_precinct_election(prec, elect).length
    end
  end
  
end
