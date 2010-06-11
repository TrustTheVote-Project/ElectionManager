require 'test_helper'

class CurrentContextTest < ActionController::TestCase
  context "Current Context "do
    setup do
      @controller = ElectionsController.new
    end
    
    context " reset on GET to ElectionsController#index " do
      setup do
        @election = Election.make
        @elections = [@election]
        Election.expects(:paginate).with(:page => "1", :per_page => 10).returns(@elections.paginate)
        get :index, :page => "1"
      end

      should_respond_with :success
      should_assign_to(:elections) { @elections }
      should_change("the number of elections", :from => 0, :to => 1) { Election.count}
      
      should "create a current_context that is reset" do
        cc = @controller.current_context
        assert cc
        assert_nil cc.jurisdiction
        assert_nil cc.election
        assert_nil cc.contest
        assert_nil cc.question
        assert_nil cc.precinct
        
        session = @controller.session
        assert_nil session[:jurisdiction_id]
        assert_nil session[:election_id]
        assert_nil session[:contest_id]
        assert_nil session[:question_id]
        assert_nil session[:precinct_id]
      end
    end

    context "add election on GET to ElectionsController#show " do
      setup do
        @election = Election.make
        Election.expects(:find).with(@election.id.to_s, {:include => [{:district_set => :districts}, {:contests => :candidates}, :questions]}).returns(@election)
        get :show, :id  => @election.id

      end
      
      should_respond_with :success
      should_assign_to(:election) { @election}
      should_render_template :show
      should_render_with_layout 'application'
      
      
      should "create a current_context has an election and jurisdiction" do
        cc = @controller.current_context
        assert cc
        assert_equal @election, cc.election
        assert_equal @election.district_set, cc.jurisdiction
        assert_nil cc.contest
        assert_nil cc.question
        assert_nil cc.precinct
      end
      
      should "create a current_context in the session that has an election and jurisdiction" do
        
        election_id = @controller.session[:election_id]
        jurisdiction_id = @controller.session[:jurisdiction_id]
        assert election_id
         assert_equal @election.id, election_id
         assert_equal @election.district_set.id, jurisdiction_id

      end

      should "not blow up for debug method" do
        s =  @controller.session
        s.to_yaml
        cc = @controller.session[:current_context]
        cc.to_yaml
        #"<pre class='debug_dump'>#{h(@session.to_yaml).gsub("  ", "&nbsp; ")}</pre>".html_safe
        #      ses = @controller.debug(@session)
        #      ses = debug(@session)
        #puts "ses = #{ses.inspect}"
      end
    end
  end
end
