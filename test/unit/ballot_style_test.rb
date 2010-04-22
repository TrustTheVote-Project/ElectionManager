require 'test_helper'

class BallotStyleTest < ActiveSupport::TestCase
  
  context "basic insert test" do
      should "able to create new Ballot Style" do
        bs = BallotStyle.new(:display_name => "test style")
        bs.save!
     end
    end
    
     def test_dbLoaded
       assert_not_nil BallotStyle.find(0), "Default Ballot Style has not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=development"
     end
end
