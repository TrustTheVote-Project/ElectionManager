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


class UserTest < ActiveSupport::TestCase
  context "User creation" do
    setup do

      User.create!(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")

    end
    subject { User.first }
    should_create :user
    should_change("the number of users", :by => 1){  User.count}
    should_validate_uniqueness_of :email
    should_validate_presence_of :email, :message => /.*is too short.*/
    should_have_instance_methods :email, :password, :password_confirmation
    #    should_have_readonly_attributes :password, :password_confirmation
    
    should "have a crypted_password" do
      assert subject.crypted_password
    end 
    
  end
  
  setup_users(:count => 3, :uname => "foo_", :dname => 'bar.com', :pwd => 'ttv' ) do
    
    subject { User.first}
    should_change("the number of users", :by => 3){  User.count}
    
    should "create the correct email" do
      assert_contains User.all.map(&:email), 'foo_0@bar.com'
    end
    

  end
  
end
