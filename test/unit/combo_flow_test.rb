require 'test_helper'
require 'ballots/default/ballot_config'

class ComboFlowTest < ActiveSupport::TestCase
  setup_jurisdictions do  
    context "DefaultBallot::FlowItem::Combo" do
      setup do
        @e1 = Election.find_by_display_name "Election 1"
        @p1 = Precinct.find_by_display_name "Precint 1"
        @scanner = TTV::Scanner.new
        @lang = 'en'
        @style = "default"
        image_instructions = 'images/test/instructions.jpg'
        
        @template = BallotStyleTemplate.make(:display_name => "test template")
        @ballot_config = DefaultBallot::BallotConfig.new( @e1, @template)        

        @ballot_config.setup(create_pdf("Test Combo Flow"),nil)
        
      end
      
      should "get the Combo flow item for Arrays" do
        assert_instance_of DefaultBallot::FlowItem::Combo, @ballot_config.create_flow_item([])
      end
      
    end
  end
end
