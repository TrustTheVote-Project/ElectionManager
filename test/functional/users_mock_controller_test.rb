require 'test_helper'

class UsersMockControllerTest < ActionController::TestCase
  context "without a logged in user" do
    
    setup do
      @controller = UsersController.new
    end
    
    # TODO: Should be able to show the users without being logged_in?
    context "on GET to :index" do    
      setup do
        tmp_user = User.make
        User.expects(:find).with(:all).returns([tmp_user])
        get :index
      end
      
      should_assign_to :users
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end # INDEX ACTION
    
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
