require 'test_helper'

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
