require 'test_helper'

class BallotStyleTemplateTest < ActiveSupport::TestCase
  
  context "Ballot Rule" do
    
    setup do
      @bst = BallotStyleTemplate.make
    end
    
    should "have an attribute with the name of the default ballot rule class" do
      assert @bst.ballot_rule_classname
      assert_equal "Default", @bst.ballot_rule_classname
    end

    should "have a method that gets the ballot rule class" do
      assert @bst.ballot_rule_class
      assert_equal TTV::BallotRule::Default,  @bst.ballot_rule_class
    end

    should "have a method that gets an instance of the ballot rule class" do
      assert @bst.ballot_rule
      assert @bst.ballot_rule.instance_of?(TTV::BallotRule::Default)
    end

    should "be able to change the ballot rule class" do
      @bst.ballot_rule_classname = "VA"
      
      assert @bst.ballot_rule_classname
      assert_equal "VA", @bst.ballot_rule_classname
      
      assert @bst.ballot_rule_class
      assert_equal TTV::BallotRule::VA,  @bst.ballot_rule_class

      assert @bst.ballot_rule
      assert @bst.ballot_rule.instance_of?(TTV::BallotRule::VA)
    end
  end
  
  context "have default ballot styles" do
    setup do
      @bst = BallotStyleTemplate.make
    end
    
    should "have default page styles" do
      assert @bst.page
      assert_kind_of Hash, @bst.page
      assert_equal @bst.page[:size], "LETTER"
      assert_equal @bst.page[:layout], :portrait
      assert_equal @bst.page[:margin],  { :top => 0, :right => 0, :bottom => 0, :left => 0}
    end
    
    should "have default frame styles" do
      assert @bst.frame
      assert_kind_of Hash, @bst.frame
      assert @bst.frame[:margin]
      assert_kind_of Hash, @bst.frame[:margin]
      assert @bst.frame[:border]
      assert_kind_of Hash, @bst.frame[:border]
      assert @bst.frame[:content]
      assert_kind_of Hash, @bst.frame[:content]
    end
    
    should "have default content styles" do
      assert @bst.contents
      assert_kind_of Hash, @bst.contents

      assert @bst.contents[:border]
      assert_kind_of Hash, @bst.contents[:border]

      assert @bst.contents[:header]
      assert_kind_of Hash, @bst.contents[:header]
      
      assert @bst.contents[:body]
      assert_kind_of Hash, @bst.contents[:body]
      
      assert @bst.contents[:footer]
      assert_kind_of Hash, @bst.contents[:footer]

    end
    
    should "have default ballot layout styles" do
      assert @bst.ballot_layout
      assert_kind_of Hash, @bst.ballot_layout
      assert @bst.ballot_layout[:create_A_headers]
      
    end
      
  end
  context "use ballot layout" do
    setup do
      @bst = BallotStyleTemplate.make
    end
    
    should "disable creation of ballot \"A\" headers" do
      @bst.ballot_layout[:create_A_headers] = false
      assert !@bst.create_A_ballot_headers?
    end
    
  end

  context "disable pdf forms " do
    setup do
      @bst = BallotStyleTemplate.make
    end
    should "have not pdf forms disabled by default" do
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
  
  context "template with instructions file attachment" do
    setup do
      @bst = BallotStyleTemplate.make(:display_name => "test template", :instructions_image_file_name => "test.png", :instructions_image_file_size => 20, :instructions_image_content_type => 'png')
      
    end
    should "have an instructions url" do
      assert_equal "/system/instructions_images/1/original/test.png", @bst.instructions_image.url
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
