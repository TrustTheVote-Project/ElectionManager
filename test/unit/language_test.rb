require 'test_helper'

class LanguageTest < ActiveSupport::TestCase
  context "basic insert test" do
      should "able to create new Language" do
        lang = Language.new(:display_name => "test language")
        lang.save!
     end
    end
    
    
    
     def test_dbLoaded
       assert_not_nil Language.find(0), "Default languages have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=development"
     end
end
