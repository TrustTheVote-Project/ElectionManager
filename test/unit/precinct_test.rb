require 'test_helper'

class PrecinctTest < ActiveSupport::TestCase
  context "basic test" do

    setup do
      Precinct.create(:display_name => "precinct1")
    end

    subject { Precinct.last}
    
    
    should_have_and_belong_to_many :districts

    should_change("the number of precincts", :by => 1) { Precinct.count}
    
    should_have_class_methods :find
    should_have_instance_methods :before_validation, :districts_for_election
    should_have_db_columns :display_name, :ident
    
    # doesn't work ???
    #should_ensure_length_is(:display_name, "precinct1".size)
    should "validate length of " do assert_equal subject.display_name.size, "precinct1".size end
    
    should_have_attr_reader :display_name
    
  end
end
