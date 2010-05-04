require 'test_helper'

class UserRoleTest < ActiveSupport::TestCase
  context "User Role" do
    
    context "with an invalid role name" do
      
      should "assert a bad value" do
        assert_bad_value(UserRole, :name, "foo", "Invalid Role")
      end
    end
    
    %w{ root standard public}.each do |role_name|
      context "with a value role name of #{role_name}" do

        should "assert a good value" do
          assert_good_value(UserRole, :name, role_name)
        end
      end
    end
    
    context "without a user " do
      setup do
        @role = UserRole.new(:name => "public")        
      end
      
      should "save" do
        assert_save @role
      end
      
      should_belong_to :user
    end
    
    context "with a user" do
      
      setup do
        @role = UserRole.make
        @role.user =  User.new(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")
        @role.save
        
      end
      subject { @role }
      should_create :user_role
      should_belong_to :user
      
      
      should "find a user with this user role" do
        user_roles = User.last.roles
        assert_equal 1, user_roles.count
       
        assert_equal subject, user_roles.last
      end
      
      

    end # end context
  end
  
  context "User with roles" do
    setup do
      role = UserRole.new(:name => "public")
      role.user =  User.new(:email => "user1@example.com", :password => "password1", :password_confirmation => "password1")
      role.save
    end
    subject { User.last}
    should_have_many :roles
    
    should "have the assigned role" do
      assert_equal subject.roles.last, UserRole.last
    end

    should "have the correct role name" do
      assert subject.role?("public")
      assert subject.role?(UserRole.last.name)
    end
    
  end
end
