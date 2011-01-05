# OSDV Election Manager - Unit Test for Ballot Style Template
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require File.dirname(__FILE__) + '/../test_helper'

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
