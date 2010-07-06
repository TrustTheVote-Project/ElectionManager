require 'test_helper'
require 'ballots/default/ballot_config.rb'

class RendererTest < ActiveSupport::TestCase
  
  setup_jurisdictions do
    
    context "AbstractBallot::Renderer " do
      
      setup do
        e1 = Election.find_by_display_name "Election 1"
        p1 = Precinct.find_by_display_name "Precint 1"
        scanner = TTV::Scanner.new
        ballot_config = DefaultBallot::BallotConfig.new('default', 'en', e1, scanner, "missing")
        
        @renderer = AbstractBallot::Renderer.new(e1, p1, nil, nil)
        
      end
      
      should "should be created " do

        assert @renderer
      end
      
      should "should be created " do
        assert @renderer
      end
      
      should "initialize all the flow items" do
        assert @renderer.init_flow_items
      end
    end # end AbstractBallot::Renderer context
    
  end # end setup_jurisdiction

end 
