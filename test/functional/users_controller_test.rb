require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  
  setup do
    # turn off automatic session creation when a user is created,
    # this is a added to the User model by authlogic
    User.maintain_sessions = false    
  end
  # Lets start off with some plain ole TestUnit tests
  
  # Right now only root users can create other users
  test "should get new" do
    get :new

    assert_redirected_to root_url
    assert_equal "Access Denied", flash[:error]

  end
  
  test "should create user" do
    
    assert_no_difference('User.count') do
      # User.plan will return a hash of the attributes for the default
      # User blueprint
      post :create, :user => User.plan
    end
    
    assert_redirected_to root_url
    assert_equal "Access Denied", flash[:error]
  end

  # Now we're gonna use Shoulda for testing
  
  # Emulates a login just creates a User and sets it in the
  # UserSession
  # This is needed to check the CanCan access control
  self.login_as(:roles => %w{public}) do    

    # Allow guest/public users to get the registration page.
    context "on GET to :register" do    
      setup do
        tmp_user = User.new
        User.expects(:new).returns(tmp_user)
        get :register
      end
      
      should_assign_to :user
      should_respond_with :success
      should_render_template :register
      should_not_set_the_flash
      
      should "create an unsaved user" do
        assert assigns(:user).new_record?
      end
    end # REGISTER ACTION
    
    # Allow guest/public users to register a user
    context "on POST to :registration_create" do    
      setup do
        # expect Notification
        Notifier.expects(:deliver_registration_confirmation).with(instance_of(User))
        assert_difference('User.count') do
          post :registration_create, :user => User.plan
        end
      end

      should_assign_to :user
      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Successfully created a new user."
      
      should "create saved user" do
        assert !assigns(:user).new_record?
      end
    end # REGISTRATION_CREATE ACTION

    # RESTRICTED ACTIONS
    # OK, Now these actions should fail without a logged in user.
    
    # Should not be able to show the users without being logged_in?
    context "on GET to :index" do    
      setup do
        get :index
      end
      
      should_redirect_to("Home page") { root_url }
      should_set_the_flash_to "Access Denied"

    end # INDEX ACTION
    
    context "on GET to :show" do    
      setup do
        @show_user = User.make(:email => "show_user@gmail.com")
        get :show, :id => @show_user.id
      end
      
    end # SHOW ACTION

    context "on GET to :edit" do    
      setup do
        @show_user = User.make(:email => "show_user@gmail.com")
        get :edit, :id => @show_user.id
      end

      should_redirect_to("Home page") { root_url }
      should_set_the_flash_to "Access Denied"

    end # EDIT ACTION
    
    context "on PUT to :update" do    
      setup do
        @show_user = User.make(:email => "show_user@gmail.com")
        put :update, :id => @show_user.id, :user => { :email => "foo@bar.com"}
      end
      
      should_redirect_to("Home page") { root_url }
      should_set_the_flash_to "Access Denied"
    end # UPDATE ACTION

    # TODO: Should probably not allow public users to destroy users.
    context "on DELETE to :destroy" do    
      setup do
        @show_user = User.make(:email => "show_user@gmail.com")
        delete :destroy, :id => @show_user.id
      end
      
      should_redirect_to("Home page") { root_url }
      should_set_the_flash_to "Access Denied"

    end # DESTROY ACTION
  end # END tests for public, not logged_in, users
  
  # These actions require a root user.
  self.login_as(:email => "logged_in_user@gmail.com", :roles => %w{root}) do
    
    # Allow guest/public users to get to the new user page/form.
    context "on GET to :register" do    
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
    
    # Allow guest/public users to create users
    context "on POST to :create" do    
      setup do
        # expect Notification
        Notifier.expects(:deliver_registration_confirmation).never
        assert_difference('User.count') do
          post :create, :user => User.plan
        end
      end

      should_assign_to :user
      should_redirect_to("Home Page") { root_url }
      
      should "create an saved user" do
        assert !assigns(:user).new_record?
      end
      
    end #CREATE ACTION

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
      
      should "show user" do 
        assert_equal  assigns(:user), @show_user
        assert_not_equal  assigns(:user), @logged_in_user
        
        assert assigns(:user).valid?
        assert_equal "show_user@gmail.com", assigns(:user).email
        assert_equal "logged_in_user@gmail.com",@logged_in_user.email
      end
    end
  end # end login_as

end 
