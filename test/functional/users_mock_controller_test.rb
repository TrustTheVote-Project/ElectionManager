require 'test_helper'

class UsersMockControllerTest < ActionController::TestCase
  self.login_as(:roles => %w{public}) do
    context "without a logged in user" do
      
      setup do
        @controller = UsersController.new
      end
      
      # Allow guest/public users from creating new users
      context "on GET to :new" do    
        setup do
          tmp_user = User.new
          User.expects(:new).never
          get :new
        end
        
        should_redirect_to("Home page") { root_url }
        should_set_the_flash_to "Access Denied"
        
      end # NEW ACTION
    end # END tests for public, not logged_in, users

  end # end login_as(:roles => %w{public})
  
  self.login_as(:roles => %w{root}) do
    context "with a logged in root user" do
      
      setup do
        @controller = UsersController.new
      end
      
      # Allow root users to create new users
      context "on GET to :new" do    
        setup do
          tmp_user = User.new
          User.expects(:new).returns(tmp_user)
          get :new
        end
        
        should_assign_to :user
        should_respond_with :success
        should_render_template :new
        should_not_set_the_flash
        
        should "create an unsaved user" do
          assert assigns(:user).new_record?
        end
      end # NEW ACTION
    end # END tests for root users

  end # end login_as(:roles => %w{root})
end
