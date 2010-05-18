require 'test_helper'

class LoginTest < ActionController::TestCase
  
  # Let's get some resources, elections, as a "public" not logged in user
  context "without a logged in user" do
    
    # get elections
    context "on GET to :index " do
      setup do
        # indicate which controller/resource we're testing
        @controller = ElectionsController.new

        # Mock the page to Election.paginate and returning a list of elections
        Election.expects(:paginate).with(:page => "1", :per_page => 10).returns([Election.make].paginate)

        # send the request
        get :index, :page => "1"
      end

      # We should not have a current user, we haven't logged in.
      should_not_assign_to :current_user

      # test success
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
      should_assign_to :elections
      
    end # END on GET to :index
    
    # get the create election form
    context "on GET to :new" do
      setup do
        @controller = ElectionsController.new
        get :new
      end
      
      # We should not have a current user, we haven't logged in.
      should_not_assign_to :current_user

      # public users can't request or create a new election
      # protected by cancan authorization
      should_respond_with :redirect
      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Access Denied"
    end
    
  end # END without a logged in user
  

  # check login as a standard user
  self.login_as(:roles => %w{ standard } ) do
    
    # The list of elections should be available to all users
    context "on GET to :index " do
      setup do
        @controller = ElectionsController.new
        Election.make
        get :index, :page => "1"
      end
      
      should_assign_to :current_user
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
      should_assign_to :elections

      should 'have a current user with a role of standard' do
        assert assigns(:current_user)
        assert_equal "standard", assigns(:current_user).roles.first.name
        assert assigns(:current_user).role?(:standard)
      end
      
      should "assign to elections (another check)" do
        assert assigns(:elections)
      end
    end # END on GET to :index

    context "on GET to :new" do
      setup do
        @controller = ElectionsController.new
        get :new
      end
      
      should_respond_with :success
      should_render_template :new
      should_not_set_the_flash
      
      should 'have a current user with a role of standard' do
        assert assigns(:current_user)
        assert_equal "standard", assigns(:current_user).roles.first.name
      end

      should "respond with success" do
        assert assigns(:current_user)
        assert_equal "standard", assigns(:current_user).roles.first.name
        assert assigns(:current_user).role?(:standard)
        assert_response :success
        assert assigns(:election).new_record?
        assert_template 'new'
      end
      
    end

  end # END "with a logged in user"

end
