require 'test_helper'

class UsersMockControllerTest < ActionController::TestCase
  self.login_as(:roles => %w{public}) do
    context "without a logged in user" do
      
      setup do
        @controller = UsersController.new
      end
      
      # Allow guest/public users to get the registration page.
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
    end # END tests for public, not logged_in, users

  end
end
