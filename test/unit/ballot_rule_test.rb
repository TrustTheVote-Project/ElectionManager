# OSDV Election Manager - Unit Test for Ballot Rules
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

class BallotRuleTest < ActiveSupport::TestCase
  class ::TTV::BallotRule::Dummy < ::TTV::BallotRule::Base
  end
  
  context "Layout Inheritence" do
    setup do
      @base_class = ::TTV::BallotRule::Base
      @va_klass = ::TTV::BallotRule::VA
      @dummy_klass = ::TTV::BallotRule::Dummy
    end
    
    should "get strategy subclasses" do
      assert  !::TTV::BallotRule::Base.rules.empty?
      assert ::TTV::BallotRule::Base.rules.include?(@va_klass)
      assert ::TTV::BallotRule::Base.rules.include?(@dummy_klass)
    end
  end  # end context
  
  context "Class methods" do
    
    setup do
      @strategy_display_name = "VA Ballot Layout"
      @base_klass = ::TTV::BallotRule::Base
      @va_klass = ::TTV::BallotRule::VA
      @dummy_klass = ::TTV::BallotRule::Dummy
    end
    
    should "find a strategy class by name" do
      assert  @base_klass.find_subclass("VA")
      assert_equal @va_klass, @base_klass.find_subclass("VA")

      assert  @base_klass.find_subclass(@va_klass)
      assert_equal @va_klass, @base_klass.find_subclass(@va_klass)
      
      assert  @base_klass.find_subclass("Dummy")
      assert_equal @dummy_klass, @base_klass.find_subclass("Dummy")
      
      assert  @base_klass.find_subclass(@dummy_klass)
      assert_equal @dummy_klass, @base_klass.find_subclass(@dummy_klass)
    end

    should "raise an NameError when finding a strategy class with an invalid string" do
      assert_raise NameError do
        @base_klass.find_subclass("VAXX")
      end
    end
    
    should "create a strategy instance by string" do
      assert  @base_klass.create_instance("VA")
      assert  @base_klass.create_instance("VA").instance_of?(@va_klass)
    end

    should "raise an NameError when creating a strategy with an invalid string" do
      assert_raise NameError do
        assert  @base_klass.find_subclass("VAX")
      end
    end
    
    should "find strategy class by display_name" do
      assert_equal @va_klass, @base_klass.find_subclass_by_display_name(@strategy_display_name)
    end
    
    should "not find a strategy for an invalid strategy display name" do
      assert_raise NameError do
        @base_klass.find_subclass_by_display_name("K" << @strategy_display_name )
      end
    end
    
    should "create a strategy for a valid strategy display name" do
      assert @base_klass.create_instance_by_display_name(@strategy_display_name).instance_of?(@va_klass)
    end
    
    should "not create a strategy for an invalid strategy display name" do
      assert_raise NameError do
        @base_klass.create_instance_by_display_name("NotAName").instance_of?(@va_klass)
      end
    end

  end

  context "Candidate party display" do
    setup do
      @default = ::TTV::BallotRule::Default.new
      @contest = nil
      create_ballot_config(true)
    end

    should "display the candidate party by default" do
      assert @default.contest_include_party(@contest)
      assert @template.contest_include_party(@contest)
    end

  end
end
