require 'pp'
require 'test_helper'

# TODO: may want to remove this test as
# Question.questions_for_precinct_election(...) is no longer used
=begin
class QuestionTest < ActiveSupport::TestCase
  
  setup_question_requesters do
    
    context "finding questions requested by districts" do
      
      should "in the first election of the first  precinct" do
        
        # find the questions that where requested by a district that is
        # including by the first election in the first precinct
        questions = Question.questions_for_precinct_election(@p1,@e1)    
        # puts "questions = #{questions.inspect}"

        # only the first 4 questions where requested by District
        # 0. Which is also part of the first election in the first precinct
        assert_equal 4, questions.size
        (0..3).each do |i|
          assert_contains questions, Question.find_by_display_name("Question #{i}")
        end

        # these questions where requested by districts not included int
        # the first eleciton of the first precint
        (4..7).each do |i|
          assert_does_not_contain questions, Question.find_by_display_name("Question #{i}")
        end
      end
      
      should "in the first election of the second precinct" do      
        questions = Question.questions_for_precinct_election(@p2,@e1)    
        assert_equal 0, questions.size
      end
      
      should "in the second election of the first precinct" do      
        questions = Question.questions_for_precinct_election(@p1,@e2)
        # puts "questions = #{questions.inspect}"
        assert_equal 0, questions.size
      end

      should "in the second election of the second precinct" do      
        questions = Question.questions_for_precinct_election(@p2,@e2)
        # puts "questions = #{questions.inspect}"
        assert_equal 4, questions.size
        (0..3).each do |i|
          assert_does_not_contain questions, Question.find_by_display_name("Question #{i}")
        end
        (4..7).each do |i|
          assert_contains questions, Question.find_by_display_name("Question #{i}")
        end
      end
    end
  end
  
end
=end
