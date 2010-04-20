require 'test_helper'

class UserRoleTest < ActiveSupport::TestCase
  context "User Role" do
    context "without a user " do
      setup do
        @role = UserRole.new(:name => "role1")        
      end
      
      should "save" do
        assert_save @role
      end
      
      should_belong_to :user
    end
    
    context "with a user" do
      
      setup do
        role = UserRole.new(:name => "role1")
        role.user =  User.new(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")
        role.save
        
      end
      subject { UserRole.first }
      should_create :user_role
      should_belong_to :user
      
      
      should "find a user with this user role" do
        user_roles = User.last.roles
        assert_equal 1, user_roles.count
        assert_equal subject, user_roles.first
      end
      
      

    end # end context
  end
  
  context "User with roles" do
    setup do
      role = UserRole.new(:name => "role1")
      role.user =  User.new(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")
      role.save
    end
    subject { User.last}
    should_have_many :roles
    
    should "have the assigned role" do
      assert_equal subject.roles.last, UserRole.last
    end

    should "have the correct role name" do
      assert subject.role?("role1")
      assert subject.role?(UserRole.last.name)
    end
    
  end
end
