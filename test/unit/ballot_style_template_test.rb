require 'test_helper'

class BallotStyleTemplateTest < ActiveSupport::TestCase
  context "basic insert test" do
     should "able to create new Ballot Style Template" do
       bst = BallotStyleTemplate.new(:display_name => "test template", :instructions_image_file_name => "test.png", :instructions_image_file_size => 20, :instructions_image_content_type => 'png')
       bst.save!
    end
   end
   
   
   def test_dbLoaded
     assert_not_nil BallotStyleTemplate.find(0), "Default Ballot Style Templates have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=development"
   end
end
