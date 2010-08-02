require 'test_helper'
require 'ttv/alert'

class AlertTest < ActiveSupport::TestCase
  context "An alert model object" do
    setup do
      @alert = Alert.new({:message => "No jurisdiction name specified.", :type => :no_jurisdiction, :options => 
            {:use_current => "Use current jurisdiction test", :abort => "Abort import"}, :default_option => :use_current})
    end
    
    should "be valid" do
      assert @alert
    end
    
    should "return values" do
      assert_equal "No jurisdiction name specified.", @alert.message
      assert_equal "Use current jurisdiction test", @alert.options[:use_current]
      assert_equal :no_jurisdiction, @alert.type
    end
  end
  
  
  context "An empty alert object" do
    setup do
      @alert = Alert.new({:type => :not_ballot_config})
    end
    
    should "instantiate with a type" do
      #@alert.type = :not_ballot_config
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
      assert_equal "This file contians jurisdiction \"Wrong Jurisdiction\"", @alert.message
    end
    
  end
end