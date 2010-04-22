require 'test_helper'

class BallotStyleTemplateTest < ActiveSupport::TestCase
  context "basic insert test" do
     should "able to create new Ballot Style Template" do
       bst = BallotStyleTemplate.new(:display_name => "test template", :instruction_text => "test ins text", :state_graphic => "test.png")
       bst.save!
    end
   end
   
   
   def test_dbLoaded
     assert_not_nil BallotStyleTemplate.find(0), "Default Ballot Style Templates have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=development"
   end
end
