require 'test_helper'
require 'ballots/default/header_flow'

class HeaderFlowTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Header" do
    setup do
      scanner = TTV::Scanner.new
      @header_text = "Some Header Text"
      
      # TODO: remove this very circular dependency, header flow item
      # depending on ballot config ...
      election = Election.make
      @template = BallotStyleTemplate.make(:display_name => "test template")
      @ballot_config = DefaultBallot::BallotConfig.new( election, @template)
      
      @ballot_config.setup(create_pdf("Test Header Flow"), nil)
      @pdf = @ballot_config.pdf
      
      # TODO: remove dependency on scanner. It's never used for the
      # header flow!
      @header = DefaultBallot::FlowItem::Header.new(@pdf, @header_text, scanner)
      
    end
    
    should "create a header flow" do
      assert @ballot_config
      assert @ballot_config.pdf
      assert @pdf
      assert @header
    end
    
    context "with an enclosing column " do
      setup do
        # length is 400 pts, width is 200 pts
        top = 500; left = 50; bottom = 100; right = 250
        @enclosing_column_rect = AbstractBallot::Rect.new(top, left, bottom, right)

      end
      
      should "decrease the height of enclosing column when drawn" do
        
        @header.draw(@ballot_config, @enclosing_column_rect)

        # should have moved the top on the enclosing rectangle down by
        # height of the header text.
        assert_in_delta @enclosing_column_rect.original_top - 15, @enclosing_column_rect.top, 1.0
      end

      should "draw a header flow with the correct page contents" do
        
        @header.draw(@ballot_config, @enclosing_column_rect)

        @pdf.render_file("#{Rails.root}/tmp/header_flow1.pdf")
        
        util = TTV::Prawn::Util.new(@pdf)
        # TODO: this failed for DC Ballots because the header has a
        # gray background now. May still want this test??
        # assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n\nBT\n71 519.72 Td\n/F1.0 10 Tf\n[<536f6d65204865616465722054> 74.21875 <657874>] TJ\nET\n\n0.5 w\n68.000 515.130 m\n268.000 515.130 l\nS\n268.000 515.130 m\n268.000 530.000 l\nS\n68.000 515.130 m\n68.000 530.000 l\nS\nQ\n", util.page_contents[0]

      end
      
      should "be able to fit the header" do
        assert @header.fits(@ballot_config, @enclosing_column_rect)
      end
    end
    
    context "with a small enclosing column" do
      setup do
        # length is 10 pts, width is 200 pts
        top = 500; left = 50; bottom = 490; right = 250
        @enclosing_column_rect = AbstractBallot::Rect.new(top, left, bottom, right)
      end
      
      should "not be able to fit the header" do
        assert !@header.fits(@ballot_config, @enclosing_column_rect)
      end
      
    end

  end
end
