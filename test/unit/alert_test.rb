require 'test_helper'
require 'ttv/alert'

class AlertTest < ActiveSupport::TestCase
  context "An empty alert object" do
    setup do
      @alert = TTV::Alert.new(:type => :not_ballot_config)
    end
    
    should "instantiate with a type" do
      assert_equal :not_ballot_config, @alert.type
    end
    
    should "store a string message" do
      @alert.message = "File is not a ballot_config"
      assert_equal "File is not a ballot_config", @alert.message
    end
    
    should "store options, a default, and a choice" do
      @alert.options = {:ignore => "Continue import", :abort => "Cancel import"}      
      assert_equal 2, @alert.options.size
      
      @alert.default_option = :ignore
      assert_equal "Continue import", @alert.options[@alert.default_option]
      
      @alert.choice = :abort
      assert_equal "Cancel import", @alert.options[@alert.choice]
    end
    
    should "print the message when converted to string" do
      @alert.message = "This file contians jurisdiction \"Wrong Jurisdiction\""
      assert_equal "This file contians jurisdiction \"Wrong Jurisdiction\"", @alert.to_s
    end
    
  end
end