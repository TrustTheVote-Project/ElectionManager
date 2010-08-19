require 'test_helper'
require 'ballots/default/contest_flow'

class ContestFlowTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Contest" do
    setup do
      
      scanner = TTV::Scanner.new
      election = Election.make(:display_name => "Election 1")
      
      
      @contest = Contest.make(:display_name => "US Senate",
                              :voting_method => VotingMethod::WINNER_TAKE_ALL,
                              :district => District.make(:display_name => "District 1"),
                              :election => election,
                              :position => 0)
      @contest_flow_height = 161
      
      [:democrat, :republican, :independent].each do |party_sym|
        party = Party.make(party_sym)
        Candidate.make(:party => party, :display_name => "#{party_sym}_Candidate", :contest => @contest)
      end
      
      @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => true)
      @ballot_config = DefaultBallot::BallotConfig.new( election, @template)
      
      @ballot_config.setup(create_pdf("Test Contest Flow"), nil) # don't need the 2nd arg precinct
      @pdf = @ballot_config.pdf
      # TODO: remove all the circular dependencies, ballot config
      # TODO: remove dependency on scanner. It's never used for the
      # flow!
      @contest_flow = DefaultBallot::FlowItem::Contest.new(@pdf, @contest, scanner)      
    end
    
    should "create a contest flow" do
      assert @ballot_config
      assert @ballot_config.pdf
      assert @pdf
      assert @contest
      assert @contest.instance_of?(Contest)
    end
    
    context "with an enclosing column " do
      setup do
        # length is 400 pts, width is 200 pts
        top = 500; left = 50; bottom = 100; right = 250
        @enclosing_column_rect = AbstractBallot::Rect.new(top, left, bottom, right)
        # draw red outline/stroke to enclosing column
        TTV::Prawn::Util.stroke_rect(@pdf, @enclosing_column_rect)
      end
      
      should "draw a contest flow with the correct page contents" do
        @contest_flow.draw(@ballot_config, @enclosing_column_rect)
        
        # TODO: Find out why the check boxes for the contest are
        # drawn outside the enclosing column.
        @pdf.render_file("#{Rails.root}/tmp/contest_flow_form.pdf")

      end
    end
  end
end
