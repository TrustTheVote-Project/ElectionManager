# OSDV Election Manager - Unit Test
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


class UserContextTest < ActiveSupport::TestCase
  
  context "basic UserContext" do
    setup do
      dummy_session = { }
      @uc = UserContext.new(dummy_session)
    end
    should "successfully be created" do
      assert_not_nil @uc
    end
    
    should "not have any context yet" do
      assert !@uc.election? && !@uc.jurisdiction
    end
    
    context "with a basic jurisdiction" do
      setup do
        @jur = DistrictSet.make
        @uc.jurisdiction = @jur
      end
      
      should "locate primary name" do
        assert_equal @jur.display_name, @uc.jurisdiction_name
      end
      
      should "locate secondary name" do
        assert_equal @jur.secondary_name, @uc.jurisdiction_secondary_name
      end
    end
    
    context "Re-created UserContext" do
      setup do
        @sess = {}
        @uc = UserContext.new(@sess)
        @jur = DistrictSet.make
        @elect = Election.make
        @cont = Contest.make
        @question = Question.make
        @prec = Precinct.make
      end
      
      should "know which was the current jurisdiction" do
        @uc.jurisdiction = @jur
        @other_uc = UserContext.new(@sess)
        assert @jur, @other_uc.jurisdiction
      end
      
      should "know that there was a current jurisdiction" do
        @uc.jurisdiction = @jur
        @other_uc = UserContext.new(@sess)
        assert @other_uc.jurisdiction?
      end

      should "know that there was a current election" do
        @uc.election = @elect
        @other_uc = UserContext.new(@sess)
        assert @other_uc.election?
      end
      
      should "know that there was a current question" do
        @uc.question = @question 
        @other_uc = UserContext.new(@sess)
        assert @other_uc.question?
      end

      should "know that there was a current contest" do
        @uc.contest = @cont
        @other_uc = UserContext.new(@sess)
        assert @other_uc.contest?
      end
      
     should "know that there was a current precinct" do
        @uc.precinct = @prec
        @other_uc = UserContext.new(@sess)
        assert @other_uc.precinct?
      end
    end
  end   
  
end
