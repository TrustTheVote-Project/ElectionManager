require 'test_helper'

class MediumTest < ActiveSupport::TestCase
  context "basic insert test" do
      should "be able to create new medium" do
        medium = Medium.new(:display_name => "test medium")
        medium.save!
     end
    end
    
     def test_dbLoaded
       assert_not_nil Medium.find(0), "Default mediums have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=development"
     end
end
