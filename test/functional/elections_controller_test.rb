require 'test_helper'

class ElectionsControllerTest < ActionController::TestCase

  context "without a logged in user" do
    
    context "on GET to :index " do
      setup do
        # create a single election
        @e1 = Election.make
        Election.expects(:paginate).with(:page => "1", :per_page => 10).returns([@e1].paginate)
        get :index, :page => "1"
      end

      should_assign_to :elections
      should_not_assign_to :election
      should_respond_with :success
      should_render_template :index
      should_not_set_the_flash

      should "get the only election" do
        assert_equal 1, assigns(:elections).size 
        assert_equal @e1, assigns(:elections).first
      end
      
      #       should "get the pagination div" do
      #         assert_select 'div.pagination'
      #       end
    end
    
    context "on GET to :index with no elections" do
      setup do
        # returning an empty array of elections
        Election.expects(:paginate).with(:page => "1", :per_page => 10).returns([].paginate)
        get :index, :page => "1"
      end

      should_assign_to :elections
      should_redirect_to("New Election") { new_election_url}
    end
  end # END "without a logged in user"
end
