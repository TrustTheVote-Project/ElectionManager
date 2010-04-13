require 'test_helper'

class QuestionTest < ActiveSupport::TestCase

  context " with an existing question" do

    setup do
      create_question
    end
    
    should_create :question    
    subject { Question.last}
    should_belong_to :election
    should_belong_to :district
    
    should "find questions by precinct and election" do
      
      precinct = Precinct.find_by_display_name "Chelmsford Precinct 3"
      questions  = Question.election_district_set_districts_precincts_id_is(precinct.id)
      assert_equal 1, questions.size
      assert_equal Question.first.display_name, questions.first.display_name
      assert_equal "Free Chicken", questions.first.display_name
    end
    
  end
  
  # TODO: Should be replaced by factories, factory-girl or machinist
  def create_question

    election = create_election_first

    question1 = Question.new(:display_name => "Free Gas", :question => "Gas for free")
    question1.district =  @district2
    question1.election =  election
    question1.save!
     
    question2 = Question.new(:display_name => "Free Chicken", :question => "A free chicken in every pot")
    question2.district =  @district1
    question2.election =  election
    question2.save!
    question2
    
  end

def create_election_first

    @district2 = District.create!(:display_name => "First Middlesex", :district_type => DistrictType::COUNTY)
    @district2.save!

    @district1 = District.create!(:display_name => "Second Middlesex", :district_type => DistrictType::COUNTY)
    @district1.precincts << Precinct.create!(:display_name => "Chelmsford Precinct 3")
    @district1.precincts << Precinct.create!(:display_name => "Chelmsford Precinct 5")
    @district1.precincts << Precinct.create!(:display_name => "Chelmsford Precinct 7")
    @district1.save!
    
    district_set = DistrictSet.create!(:display_name => "Middlesex County")
    district_set.districts << @district1
    district_set.save!
    
    voting_method = VotingMethod.create!(:display_name =>"Winner Take All")
    election = Election.create!(:display_name => "2008 Massachusetts State", :district_set => district_set)

  end

end
