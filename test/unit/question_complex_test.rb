# OSDV Election Manager - Unit Test
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
require File.dirname(__FILE__) + '/../test_helper'

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
