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


class JurisdictionMembershipTest < ActiveSupport::TestCase
  
  context "Creating Jurisdiction Memberships: User " do
    setup do
      @user =  User.make
      @juris =  DistrictSet.make
      @juris_user = JurisdictionMembership.make(:user =>@user, :district_set => @juris)
      @juris_user.save
    end

    subject { @user }
    should_have_many :jurisdiction_memberships
    should_have_many :jurisdictions, :through => :jurisdiction_memberships
    
    should "have only one jurisdiction membership" do
      assert_equal 1, subject.jurisdiction_memberships.count
    end
    should "have the correct number jurisdiction user relations" do
      assert_equal @juris_user, subject.jurisdiction_memberships.first
    end
    should "have a jurisdiction user relation with a  role of standard" do
      assert_equal "standard", subject.jurisdiction_memberships.first.role
    end
    should "be part of the correct jurisidiction" do
      assert_equal @juris, subject.jurisdiction_memberships.first.district_set
    end
  end
  
  context "Adding a jurisdiction to a user: User " do
    setup do
      @user =  User.make
      @juris =  DistrictSet.make
      @user.jurisdictions << @juris
      @user.save!
    end
    subject { @user }
    should_have_many :jurisdictions

    should "have only the one jurisdiction" do
      assert_equal 1, subject.jurisdictions.count
    end

    should "have the correct jurisdiction" do
      assert_equal @juris, subject.jurisdictions.first
    end
    should "be a standard member of this jurisdiction" do
      assert_equal "standard", subject.jurisdiction_memberships.first.role
      assert !subject.jurisdiction_admin?
      assert subject.jurisdiction_member?(@juris)
    end
  end  
  
  context "Adding a user to a jurisdiction: Jurisdiction " do
    setup do
      @user =  User.make
      @juris =  DistrictSet.make
      @juris.users << @user
      @juris.save!
    end
    subject { @juris }
    should_have_many :users

    should "have only the one user" do
      assert_equal 1, subject.users.count
    end

    should "have the correct user" do
      assert_equal @user, subject.users.first
    end
    
    should "should have a user with a role of standard" do
      assert_equal "standard", subject.jurisdiction_memberships.first.role
    end
  end

  context "Assigning jurisdictions roles to users: " do

    JurisdictionMembership::ROLE_NAMES.each do |role_name|
      context "User " do 
        setup do
          @user =  User.make
          @juris =  DistrictSet.make
          @juris_user = JurisdictionMembership.make(:user =>@user, :district_set => @juris, :role => role_name)
          @juris_user.save
        end
        
        setup { @user }
        
        should "(#{role_name}) be a member of the jurisdiction assigned" do
          assert @user.jurisdiction_member?(@juris)
        end

        should "be a member of the jurisdiction with a role of #{role_name}" do
          assert role_name, @user.jurisdiction_memberships.first.role
        end
        
        should "should" << (role_name == "admin" ? "": " not") << " be a jurisdiction admin" do
          assert (role_name == 'admin' ? @user.jurisdiction_admin? : !@user.jurisdiction_admin?)
        end
      end
    end
  end
end
