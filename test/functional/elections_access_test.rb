require 'test_helper'

class ElectionsControllerAccessTest < ActionController::TestCase

  context "without a logged in user" do
    
    setup do
      # need to set the controller cuz the test name != controller name
      @controller = ElectionsController.new
      
      # create Election from blueprint
      @e1 = Election.make
    end
    
    # allow a public user to see all of the elections
    context "on GET to :index " do
      
      setup do
        Election.expects(:paginate).with(:page => "1", :per_page => 10).returns([@e1].paginate)
        get :index, :page => "1"
      end

      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash
    end

    # allow a public user to see a specific election
    context "on GET to :show" do
      
      setup do
        #TODO: why does this action call Election.find twice? 
        Election.expects(:find).with(@e1.id.to_s, {:include => [{:district_set => :districts}, {:contests => :candidates}, :questions]}).returns(@e1)
        Election.expects(:find).with(@e1.id.to_s).returns(@e1)
        
        get :show, :id => @e1.id
      end

      should_respond_with :success
      should_render_template :show
      should_not_set_the_flash
    end
    
    # prevent public users from creating new elections
    context "on GET to :new" do
      setup do
        get :new
      end

      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Access Denied"

    end
    
    # prevent public users from creating new elections
    context "on POST to :create" do
      setup do
        post :create, :election => Election.plan
      end

      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Access Denied"

    end
    
    # prevent public users from updating an elections
    context "on GET to :edit" do
      setup do
        get :edit, :id => @e1.id
      end
      
      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Access Denied"
      
    end
    
    # prevent public users from updating an elections
    context "on PUT to :update" do
      setup do
        put :update, :id => @e1.id, :election => @e1.attributes
      end
      
      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Access Denied"
    end

    context "on DELETE to :destroy" do
      setup do
        delete :destroy, :id => @e1.id
      end

      should_redirect_to("Home Page") { root_url }
      should_set_the_flash_to "Access Denied"

    end
  end # END "without a logged in user"
end
