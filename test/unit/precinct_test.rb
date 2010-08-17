require 'test_helper'

class PrecinctTest < ActiveSupport::TestCase
  context "basic test" do
    
    setup do
      Precinct.create(:display_name => "precinct1")
    end
    
    subject { Precinct.last}
    should_create :precinct
    should_change("the number of precincts", :by => 1) { Precinct.count}    
    #    should_have_and_belong_to_many :districts
    should_have_class_methods :find
    should_have_instance_methods :before_validation, :districts_for_election
    should_have_db_columns :display_name, :ident
    should_have_attr_reader :display_name
    
    should_ensure_length_is(:display_name, "precinct1".size)
    should "validate length of " do assert_equal subject.display_name.size, "precinct1".size end
    should "have an identity" do
      assert !subject.ident.blank?
    end
    
  end
  
  setup_precincts do
    subject { Precinct.find_by_display_name "Precinct 1"}
    puts subject.inspect
    
    should "have a couple of districts" do
      assert_equal 4,  subject.precinct_splits[0].district_set.districts.count
       (0..3).each do |i|
        assert_equal "District #{i}", subject.precinct_split[0].district_set.districts.find_by_display_name("District #{i}").display_name
      end
    end
  end
  
  setup_jurisdictions do
    
    should "districts that are part of an election" do
      election1 = Election.find_by_display_name("Election 1")
      assert_equal 2, subject.districts_for_election(election1).size
      assert_contains subject.districts_for_election(election1), subject.districts.first
      assert_does_not_contain subject.districts_for_election(election1), District.last
    end
    
  end 
end
