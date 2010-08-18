require 'test_helper'

class PrecinctTest < ActiveSupport::TestCase
  context "basic test" do  
    setup do
      @precinct = Precinct.create!(:display_name => "precinct1")
    end
    
    should_create :precinct
    should_change("the number of precincts", :by => 1) { Precinct.count}    
    should_have_class_methods :find
    should_have_instance_methods :before_validation, :districts_for_election
    should have_db_column :display_name
    should have_db_column :ident
    should_have_attr_reader :display_name
    should ensure_length_of(:display_name).is_equal_to(9).with_message(/is invalid/)
    should "have an identity" do
      assert !@precinct.ident.blank?
    end    
  end
  
  setup_precincts do    
    should "@p1 have 1 split" do
      assert_equal 1, @p1.precinct_splits.length
    end
    
    should "have 3 disricts in that split" do
      assert_equal 3,  @p1.precinct_splits[0].district_set.districts.count
    end
  end

  
# TODO: 
#  setup_jurisdictions do
#    
#    should "districts that are part of an election" do
#      election1 = Election.find_by_display_name("Election 1")
#      assert_equal 2, subject.districts_for_election(election1).size
#      assert_contains subject.districts_for_election(election1), subject.districts.first
#      assert_does_not_contain subject.districts_for_election(election1), District.last
#    end
#    
#  end 
end
