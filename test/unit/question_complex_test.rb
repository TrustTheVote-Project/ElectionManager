require 'pp'
require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  context "finding questions requested by districts" do

    setup do
      
      # create a precint within 4 Districts
      @p1 = Precinct.create!(:display_name => "Precint 1")
      (0..3).each do |i|
        @p1.districts << District.new(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
      end
      
      # create another precint with another set of 4 Districts
      @p2 = Precinct.create!(:display_name => "Precint 2")      
      (4..7).each do |i|
        @p2.districts << District.create!(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
      end

      # create a set of districts that are not associated with any precincts
      (8..11).each do |i|
        District.create!(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
      end
      
      # create a district set with only the first 2 districts in the
      # first precinct
      ds1  = DistrictSet.create!(:display_name => "District Set 1")
      ds1.districts << District.find_by_display_name("District 0")
      ds1.districts << District.find_by_display_name("District 1")
      ds1.save!
      
      # create another district set that is associated first 2 districts
      # in the second precinct
      ds2  = DistrictSet.create!(:display_name => "District Set 2")
      ds2.districts << District.find_by_display_name("District 4")
      ds2.districts << District.find_by_display_name("District 5")
      ds2.save!

      # create 2 elections each associated with a district set
      @e1 = Election.create!(:display_name => "Election 1", :district_set => ds1)
      @e2 = Election.create!(:display_name => "Election 2", :district_set => ds2)

      # create 4 questions that where requested by the district 0,
      # district 0 is associated with the first precinct 
      d0 =  District.find_by_display_name("District 0")
      (0..3).each do |i|
        q = Question.new(:display_name => "Question #{i}", :question => "what is #{i}")
        q.requesting_district = d0
        q.election = @e1
        q.save!
      end

      # create 4 questions that where requested by the district 4,
      # district 2 is overlaps the second precinct 
      d4 =  District.find_by_display_name("District 4")
      
      (4..7).each do |i|
       q = Question.new(:display_name => "Question #{i}", :question => "what is #{i}")
        q.requesting_district = d4
        q.election = @e2
        q.save!

      end
    end

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
