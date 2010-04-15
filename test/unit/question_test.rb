require 'pp'
require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  context " with an existing question" do

    setup do
      create_questions
    end
    
#    should_create :question    
    subject { Question.last}
    should_belong_to :election
    should_belong_to :requesting_district

    should 'have a requesting district' do
      assert subject.requesting_district
    end
    
    should 'be able to change the requesting district' do

      q1 = Question.first
      # original requesting district 
      assert_equal District.find(1), q1.requesting_district(true)
      
      # change requesting district
      q1.requesting_district = District.find(0)
      q1.save!

      assert_not_equal District.find(1), q1.requesting_district(true)
      assert_equal District.find(0), q1.requesting_district(true)
      
    end
  
    if false
      should "find questions by precinct and election" do
      
        precinct = Precinct.find_by_display_name "Chelmsford Precinct 3"
        questions  = Question.election_district_set_districts_precincts_id_is(precinct.id)
        assert_equal 1, questions.size
        assert_equal Question.first.display_name, questions.first.display_name
        assert_equal "Free Chicken", questions.first.display_name
      end
    end
    
    # I think this algorithmically does what we want. How to turn it into 
    # SQL is the question...   
    should " find questions for specified precinct and election" do
      # get all districts are covered by the desired election
      dist_from_elect = @el.district_set.districts
      
      # get all districts that are contained in the desired precinct
      dist_from_prec = @prec1.districts(@el.district_set)
      
      # find districts that are in intersection
      dist_intersect = dist_from_elect & dist_from_prec

      # iterate over all questions. Include a question in the result if it applies to
      # this election and it was posed by one of the applicable districts
      all_questions = Question.all
      result = []
      all_questions.each do |q|
        if q.election == @el && dist_intersect.include?(q.requesting_district)
          result << q
        end
      end
      puts result
    end
  end
  
  # TODO: Should be replaced by factories, factory-girl or machinist
  def create_questions

    create_election_first

    @q1 = Question.new(:display_name => "Free Gas", :question => "Gas for free")
    @q1.requesting_district =  @district2
    @q1.election =  @el
    @q1.save!
     
    @q2 = Question.new(:display_name => "Free Chicken", :question => "A free chicken in every pot")
    @q2.requesting_district =  @district1
    @q2.election = @el
    @q2.save!
    
  end

def create_election_first

    @district2 = District.create!(:display_name => "First Middlesex", :district_type => DistrictType::COUNTY)
    @district2.save!

    @district1 = District.create!(:display_name => "Second Middlesex", :district_type => DistrictType::COUNTY)
    @prec1 = Precinct.create!(:display_name => "Chelmsford Precinct 3")
    @prec2 = Precinct.create!(:display_name => "Chelmsford Precinct 5")
    @prec3 = Precinct.create!(:display_name => "Chelmsford Precinct 7")

    @district1.precincts << @prec1
    @district1.precincts << @prec2
    @district1.precincts << @prec3
    @district1.save!
    
    district_set = DistrictSet.create!(:display_name => "Middlesex County")
    district_set.districts << @district1
    district_set.save!
    
    voting_method = VotingMethod.create!(:display_name =>"Winner Take All")
    @el = Election.create!(:display_name => "2008 Massachusetts State", :district_set => district_set)

  end

end
