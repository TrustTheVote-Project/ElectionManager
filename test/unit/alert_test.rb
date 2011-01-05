# OSDV Election Manager - Unit Test for Alert Model
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

class AlertTest < ActiveSupport::TestCase
  context "An alert model object" do
    setup do
      @alert = Alert.new({:message => "No jurisdiction name specified.", :alert_type => :no_jurisdiction, :options => 
            {:use_current => "Use current jurisdiction test", :abort => "Abort import"}, :default_option => :use_current})
    end
    
    should "be valid" do
      assert @alert
    end
    
    should "return values" do
      assert_equal "No jurisdiction name specified.", @alert.message
      assert_equal "Use current jurisdiction test", @alert.options[:use_current]
      assert_equal :no_jurisdiction, @alert.alert_type
    end
  end
  
  
  context "An empty alert object" do
    setup do
      @alert = Alert.new(:alert_type => :not_ballot_config)
    end
    
    should "instantiate with a type" do
      #@alert.type = :not_ballot_config
      assert_equal :not_ballot_config, @alert.alert_type
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