require 'test_helper'

class BallotStyleTemplateTest < ActiveSupport::TestCase
  context "disable pdf forms " do
    setup do
      @bst = BallotStyleTemplate.make
    end
    should "have pdf forms disabled by default" do
      assert !@bst.pdf_form?
    end
  end
  
  context "enable pdf forms " do
    setup do
      @bst = BallotStyleTemplate.make(:pdf_form => true)
    end
    should "have pdf forms disabled by default" do
      assert @bst.pdf_form
      assert @bst.pdf_form?
    end
  end
  
  context "winner take all" do
    setup do
      @bst = BallotStyleTemplate.make(:pdf_form => true)
    end
    should "be winner take all" do

      #    assert_equal VotingMethod::WINNER_TAKE_ALL, @bst.default_voting_method
    end
  end

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
