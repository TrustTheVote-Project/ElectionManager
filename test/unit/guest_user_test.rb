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

=begin
class GuestUserTest < ActiveSupport::TestCase
  context "Guest User" do
    
    setup do
      role = UserRole.new(:name => "public")
      role.user =  User.new(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")
      role.save

      @ability = Ability.new(User.first)
    end

    subject { User.last }
    should_have_many :roles

    should "have a public role " do
      assert subject.role? 'public'
      assert subject.role? :public
    end
    
    %w{ Candidate Contest District DistrictSet DistrictType Election Precinct Question User UserRole UserSession VotingMethod}.each do |model|
      

      should "not be allowed to create a #{model}" do
        assert @ability.cannot?(:create, model)
      end

      should "not be allowed to edit a #{model}" do
        assert @ability.cannot?(:edit, model)
      end

      should "be allowed to read a #{model}" do
        assert @ability.can?(:read, model)
      end

      should "not be allowed to destroy a #{model}" do
        assert @ability.cannot?(:destroy, model)
      end
    end #
    
    should "not allowed to create a YAMLExport model" do
      assert @ability.cannot?(:create, TTV::YAMLExport)
    end

    should "not allowed to create a YAMLImport model" do
      assert @ability.cannot?(:create, TTV::YAMLImport)
    end
    
  end
    
end
=end
