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

class QuestionTest < ActiveSupport::TestCase
  
  context " with an existing question" do
    
    setup do
      create_questions
    end
    
    #    should_create :question    
    
    subject { Question.last}
    should belong_to :election
    should belong_to :requesting_district
    
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
    
    #
    # This fairly tricky test embodies the semantics of the model. 
    #  
    should " find questions for specified precinct (@prec1) and election (@el) (assume no splits)" do
    assert !@prec1.split?
    all_dist_in_prec = @prec1.precinct_splits[0].district_set.districts
    assert all_dist_in_prec.length > 0
    
    q_in_el = @el.questions.reduce([]) do
      |memo, one|
       (all_dist_in_prec.member? one.requesting_district) ? memo << one : memo   
    end
    assert_equal 1, q_in_el.length
    assert_equal "Free Gas", q_in_el[0].display_name
  end
end

#
# Create some questions and context. precincts, districts and an election. Can this be done better with Machinist?
#
def create_questions
  
  create_election_first
  
  @q1 = Question.new(:display_name => "Free Gas", :question => "Gas for free")
  @q1.requesting_district =  @prec1.precinct_splits[0].district_set.districts[0]
  @el.questions << @q1
  @q1.save!
  
  @q2 = Question.new(:display_name => "Free Chicken", :question => "A free chicken in every pot")
  @q2.requesting_district =  @prec2.precinct_splits[0].district_set.districts[1]
  @el.questions << @q2
  @q2.save!
  @el.save    
end

#
# Create some precincts, districts and an election. Can this be done better with Machinist?
#
def create_election_first
  
  setup_precinct "Chelmsford 1", 1
  @prec1 = @prec_new
  setup_precinct "Chelsmford 2", 1
  @prec2 = @prec_new
  
  district_set = DistrictSet.create!(:display_name => "Middlesex County")
  district_set.districts << @prec1.precinct_splits[0].district_set.districts
  district_set.districts << @prec2.precinct_splits[0].district_set.districts
  district_set.save!
  
  voting_method = VotingMethod.create!(:display_name =>"Winner Take All")
  @el = Election.create!(:display_name => "2008 Massachusetts State", :district_set => district_set)
  
end

end
