require 'test_helper'
require 'ballots/default/header_flow'

class QuestionFlowTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Question" do
    setup do
      
      scanner = TTV::Scanner.new
      election = Election.make(:display_name => "Election 1")
      
      @question = Question.make(:display_name => "Dog Racing",
                                :election => election,
                                :requesting_district => District.make(:display_name => "District 1"),
                                :question => 'This proposed law would ')
      
      
      @template = BallotStyleTemplate.make(:display_name => "test template")
      @ballot_config = DefaultBallot::BallotConfig.new( election, @template)

      @ballot_config.setup(create_pdf("Test Question Flow"), nil) # don't need the 2nd arg precinct
      @pdf = @ballot_config.pdf
      # TODO: remove all the circular dependencies, ballot config
      # depends on Question flow which depends on ballot config.
      # Question.
      # Make Question flow dependent on a Question object and it's
      # enclosing column?
      # TODO: remove dependency on scanner. It's never used for the
      # flow!
      @question_flow = DefaultBallot::FlowItem::Question.new(@pdf, @question, scanner)
      @question_flow_height = 114
      
    end
    
    should "create a question flow" do
      assert @ballot_config
      assert @ballot_config.pdf
      assert @pdf
      assert @question
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
        @question_flow.draw(@ballot_config, @enclosing_column_rect)
        # should have moved the top on the enclosing rectangle down
        assert_in_delta @enclosing_column_rect.original_top - @question_flow_height, @enclosing_column_rect.top, 1.0
      end

      should "draw a question flow with the correct page contents" do

        @question_flow.draw(@ballot_config, @enclosing_column_rect)
        
        # TODO: Find out why the check boxes for the question are
        # drawn outside the enclosing column.
        # some very black magic with BallotConfig#draw_checkbox and
        # Scanner#align_checkbox
        @pdf.render_file("#{Rails.root}/tmp/question_flow1.pdf")
        
        util = TTV::Prawn::Util.new(@pdf)
        assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 0.000 0.000 SCN\n68.000 530.000 m\n268.000 530.000 l\nS\n68.000 530.000 m\n68.000 130.000 l\nS\n68.000 130.000 m\n268.000 130.000 l\nS\n268.000 130.000 m\n268.000 530.000 l\nS\n0.863 0.863 0.863 scn\n68.000 499.184 200.000 30.816 re\nf\n0.000 0.000 0.000 scn\n\nBT\n144.25 519.72 Td\n/F2.0 10 Tf\n<446f6720526163696e67> Tj\nET\n\n\nBT\n123.456875 506.306 Td\n/F2.0 8 Tf\n[<56> 74.21875 <6f746520666f72206e6f74206d6f7265207468616e20283129>] TJ\nET\n\n\nBT\n80 489.154 Td\n/F1.0 10 Tf\n<546869732070726f706f736564206c617720776f756c64> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 448.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68 450.72 Td\n/F1.0 10 Tf\n<596573> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 420.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68 422.72 Td\n/F1.0 10 Tf\n<4e6f> Tj\nET\n\n0.5 w\n0.5 w\n68.000 416.320 m\n268.000 416.320 l\nS\n268.000 416.320 m\n268.000 530.000 l\nS\n68.000 416.320 m\n68.000 530.000 l\nS\nQ\n", util.page_contents[0]


      end
    end
    
    context "with a small enclosing column" do
      setup do
        # length is 10 pts, width is 200 pts
        top = 500; left = 50
        # enclosing column is 1pt shorter than the question flow height
        bottom = top - (@question_flow_height-1)
        right = 250
        @enclosing_column_rect = AbstractBallot::Rect.new(top, left, bottom, right)
      end
      
      should "not be able to fit the question" do
        assert !@question_flow.fits(@ballot_config, @enclosing_column_rect)
      end
    end

  end
end
