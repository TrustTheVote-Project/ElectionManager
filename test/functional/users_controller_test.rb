require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  # Lets start off with some plain ole TestUnit tests
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:users)
    assert_template 'index'
  end

  test "should get new" do
    get :new
    assert_response :success
    assert assigns(:user).new_record?
    assert_template 'new'
  end
  
  test "should create user" do
    
    # expect Notification
    Notifier.expects(:deliver_registration_confirmation).with(instance_of(User))
    
    assert_difference('User.count') do
      # User.plan will return a hash of the attributes for the default
      # User blueprint
      post :create, :user => User.plan
    end
    
    assert !assigns(:user).new_record?
    assert assigns(:user).valid?
    assert_redirected_to root_url
    assert_equal "Registration successful.", flash[:notice]
  end
  
  # Now we're gonna use Shoulda for testing
  
  context "without a logged in user" do
    
    context "on GET to :index" do    
      setup do
        get :index
      end
   
      should_assign_to :users
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end 
    
    context "on GET to :new" do    
      setup do
        get :new
      end
   
      should_assign_to :user
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      
      should "create an unsaved user" do
        assert assigns(:user).new_record?
      end
    end 
  end
  
  # These actions require a logged in user.
  self.login_as(:email => "logged_in_user@gmail.com") do

    context "on GET to :show" do
      
      setup do
        @show_user = User.make(:email => "show_user@gmail.com")
        #User.expects(:find).with(:first, { :conditions => { :id => @show_user.id.to_i} }).returns(@show_user)
        get :show, :id => @show_user.id
      end
      
      subject { @show_user}
      should_assign_to :user
      should_respond_with :success
      should_render_template :show
      should_not_set_the_flash
      
      should "show user" do 
        assert_equal  assigns(:user), subject
        assert_not_equal  assigns(:user), @logged_in_user
        
        assert assigns(:user).valid?
        assert_equal "show_user@gmail.com", assigns(:user).email
        assert_equal "logged_in_user@gmail.com",@logged_in_user.email
      end
    end
  end # end login_as
  
  # make sure we handle attempting to access an action without logged
  # in user.
  context "without a logged in user" do
    context "on GET to :show" do    
      setup do
        @show_user = User.make(:email => "show_user@gmail.com")
        get :show, :id => @show_user.id
      end
      
      should_redirect_to("Login page") { new_user_session_url }
      should_set_the_flash_to "You must be logged in to access this page"
    end
  end
  
end
