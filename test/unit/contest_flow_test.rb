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

      # TODO: remove all the circular dependencies, ballot config
      # TODO: remove dependency on scanner. It's never used for the
      # flow!
      @contest_flow = DefaultBallot::FlowItem::Contest.new(@contest, scanner)
      
      @ballot_config = DefaultBallot::BallotConfig.new('default', 'en', election, scanner, "missing")
      @ballot_config.setup(create_pdf("Test Contest Flow"), nil) # don't need the 2nd arg precinct
      @pdf = @ballot_config.pdf
      
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
      
      should "decrease the height of enclosing column when drawn" do
        @contest_flow.draw(@ballot_config, @enclosing_column_rect)
        # should have moved the top on the enclosing rectangle down
        assert_in_delta @enclosing_column_rect.original_top - @contest_flow_height, @enclosing_column_rect.top, 1.0
      end
      
      should "draw a contest flow with the correct page contents" do
        @contest_flow.draw(@ballot_config, @enclosing_column_rect)
        
        # TODO: Find out why the check boxes for the contest are
        # drawn outside the enclosing column.
        @pdf.render_file("#{Rails.root}/tmp/contest_flow1.pdf")

         util = TTV::Prawn::Util.new(@pdf)
        #assert_equal "foo", util.page_contents[0]
        assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 0.000 0.000 SCN\n68.000 530.000 m\n268.000 530.000 l\nS\n68.000 530.000 m\n68.000 130.000 l\nS\n68.000 130.000 m\n268.000 130.000 l\nS\n268.000 130.000 m\n268.000 530.000 l\nS\n\nBT\n71 519.72 Td\n/F1.0 10 Tf\n<55532053656e617465> Tj\nET\n\n\nBT\n71 504.85 Td\n/F1.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 476.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68 478.72 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n68 468.04 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 448.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68 450.72 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n68 440.04 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 420.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68 422.72 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n68 412.04 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 392.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68 394.72 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n68.000 375.320 m\n262.000 375.320 l\nS\n[] 0 d\n0.5 w\n68.000 369.320 m\n268.000 369.320 l\nS\n268.000 369.320 m\n268.000 530.000 l\nS\n68.000 369.320 m\n68.000 530.000 l\nS\nQ\n", util.page_contents[0]
      end
    end
    context "with a small enclosing column" do
      setup do
        # length is 10 pts, width is 200 pts
        top = 500; left = 50
        # enclosing column is 1pt shorter than the contest flow height
        bottom = top - (@contest_flow_height-1)
        right = 250
        @enclosing_column_rect = AbstractBallot::Rect.new(top, left, bottom, right)
      end
      
      should "not be able to fit the contest" do
        assert !@contest_flow.fits(@ballot_config, @enclosing_column_rect)
      end
    end

  end
end
