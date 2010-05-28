require 'test_helper'

class ElectionsControllerAccessTest < ActionController::TestCase
  
  
  context "election access" do
    setup do
      # need to set the controller cuz the test name != controller name
      @controller = ElectionsController.new
      # create Election from blueprint
      @e1 = Election.make
    end
    
    context "without a logged in user" do
      
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
          # mock the complex Election.find 
          Election.expects(:find).with(@e1.id.to_s, {:include => [{:district_set => :districts}, {:contests => :candidates}, :questions]}).returns(@e1)
          
          get :show, :id => @e1.id
        end

        should_respond_with :success
        should_render_template :show
        should_not_set_the_flash
      end
      
      # prevent public users from creating new elections
      context "on GET to :new" do
        setup do
          # Make user Election.new is never called
          # public users can't access the new action
          Election.expects(:new).never
          get :new
        end

        should_redirect_to("Home Page") { root_url }
        should_set_the_flash_to "Access Denied"
      end
      
      # prevent public users from creating new elections
      context "on POST to :create" do
        setup do

          # make sure the number of elections doesn't change.
          assert_no_difference "Election.count" do
            post :create, :election => Election.plan
          end
        end

        should_redirect_to("Home Page") { root_url }
        should_set_the_flash_to "Access Denied"

      end
      
      # prevent public users from updating an election
      context "on GET to :edit" do
        setup do
          # make sure Election.find(id) is never called
          # public users can't access the edit action
          Election.expects(:find).never
          get :edit, :id => @e1.id
        end
        
        should_redirect_to("Home Page") { root_url }
        should_set_the_flash_to "Access Denied"
        
      end
      
      # prevent public users from updating an election
      context "on PUT to :update" do
        setup do
          # make sure Election.find(id) is never called
          # public users can't access the update action
          Election.expects(:find).never
          
          put :update, :id => @e1.id, :election => @e1.attributes
        end
        
        should_redirect_to("Home Page") { root_url }
        should_set_the_flash_to "Access Denied"
      end

      context "on DELETE to :destroy" do
        setup do
          # make sure Election.find(id) is never called
          # public users can't access the destroy action
          Election.expects(:find).never
          delete :destroy, :id => @e1.id
        end

        should_redirect_to("Home Page") { root_url }
        should_set_the_flash_to "Access Denied"

      end
    end # END "without a logged in user"
  end
  
  # with a logged in user
  self.login_as(:roles => %w{standard }) do
    context "election access" do
      
      setup do
        @controller = ElectionsController.new
        @election = Election.make
      end     

      # Users with the role of 'standard' can access all the actions
      context "on GET to :index " do
        setup do
          Election.expects(:paginate).with(:page => "1", :per_page => 10).returns([Election.make].paginate)
          get :index, :page => "1"
        end
        
        should_respond_with :success
        should_render_template :index
        should_not_set_the_flash
        
        should 'have a current user with a role of standard' do
          assert assigns(:current_user)
          assert_equal "standard", assigns(:current_user).roles.first.name
          assert assigns(:current_user).role?(:standard)
        end
      end

      context "on GET to :show" do
        setup do
          # mock the complex Election.find 
          Election.expects(:find).with(@election.id.to_s, {:include => [{:district_set => :districts}, {:contests => :candidates}, :questions]}).returns(@election)
          
          get :show, :id => @election.id
        end
        
        should_assign_to :election
        should_respond_with :success
        should_render_template :show
        should_not_set_the_flash
      end
      
      context "on GET to :new" do
        setup do
          get :new
        end

        should_assign_to :election
        should_respond_with :success
        should_render_template :new
        should_not_set_the_flash

        should "create a new election record" do
          assert assigns(:election).new_record?
        end
      end

      context "on POST to :create" do
        setup do
          #          Election.expects(:new).with(@election.attributes).returns(@election)
          assert_difference "Election.count", 1 do
            post :create, :election => @election.attributes
          end
        end
        
        should_respond_with :redirect
        should_assign_to :election
        should_set_the_flash_to /Election was successfully created/
        
        should "redirect to show the election created" do
          assert_redirected_to election_url(assigns(:election).id)
        end
        
        should "create an election with the same display_name " do
          assert assigns(:election)
          assert_equal @election.display_name,  assigns(:election).display_name
        end

      end

      context "on GET to :edit" do
        setup do
          Election.expects(:find).returns(@election)
          get :edit, :id => @election.id
        end
        
        should_assign_to :election
        should_respond_with :success
        should_render_template :edit
        should_not_set_the_flash
      end

      context "on PUT to :update" do
        setup do
          #Election.expects(:find).with(@election.id).returns(@election)
          put :update, :id => @election.id, :election => { :display_name => "new_display_name"}
        end

        should_assign_to :election
        should_respond_with :redirect
        should_set_the_flash_to /Election was successfully updated/
        
        should "update an election display_name " do
          assert assigns(:election)
          assert_equal "new_display_name",  assigns(:election).display_name
        end
        
        should_redirect_to("Elections") {election_url(@election.id)}
        should "redirect to show the election updated" do
          assert_redirected_to election_url(@election.id)
        end
      end

      context "on DELETE to :destroy" do
        setup do
          # Election.expects(:find).with(@election.id).returns(@election)
          delete :destroy, :id => @election.id
        end
        
        should_assign_to :election
        should_respond_with :redirect
        should_redirect_to("Elections") {elections_url}
        should_not_set_the_flash

      end

    end # END "with a logged in user"
  end

end
