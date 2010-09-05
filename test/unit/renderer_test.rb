require 'test_helper'
require 'ballots/default/ballot_config.rb'

class RendererTest < ActiveSupport::TestCase
  
  context "AbstractBallot::Renderer " do
    
    setup do
      
      # create a precint within 4 Districts
      p1 = Precinct.create!(:display_name => "Precint 1")
      (0..3).each do |i|
        p1.districts << District.new(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
      end
      p1.save
      
      # create a jurisdiction with only the first 2 districts 
      ds1  = DistrictSet.create!(:display_name => "District Set 1")
      ds1.districts << District.find_by_display_name("District 0")
      ds1.districts << District.find_by_display_name("District 1")
      ds1.save!

      # make an election for this jurisdiction
      e1 = Election.create!(:display_name => "Election 1", :district_set => ds1)
      e1.start_date = DateTime.new(2009, 11,3)

      # OK, now we have a precinct that contains districts 0 to 3
      # And an election that has districts 0 and 1
      
      # Create 3 contests for this election
      pos = 0;
      ["State Rep", "Attorney General","Governor"].each do |contest_name|
        contest = Contest.make(:display_name => contest_name,
                               :voting_method => VotingMethod::WINNER_TAKE_ALL,
                               :district => e1.district_set.districts.first,
                               :election => e1, :position => pos)
        pos += 1
        [:democrat, :republican, :independent].each do |party_sym|
          party = Party.make(party_sym)
          Candidate.make(:party => party, :display_name => "#{party_sym}_Candidate", :contest => contest)
        end
      end
      
      Question.make(:display_name => "Dog Racing",
                    :election => e1,
                    :requesting_district => e1.district_set.districts.first,
                    :question => 'This proposed law would prohibit any dog racing or racing meeting in Massachusetts where any form of betting or wagering on the speed or ability of dogs occurs. The State Racing Commission would be prohibited from accepting or approving any application or request for racing dates for dog racing. Any person violating the proposed law could be required to pay a civil penalty of not less than $20,000 to the Commission. The penalty would be used for the Commission\'s administrative purposes, subject to appropriation by the state Legislature. All existing parts of the chapter of the state\'s General Laws concerning dog and horse racing meetings would be interpreted as if they did not refer to dogs. These changes would take effect January 1, 2010. The proposed law states that if any of its parts were declared invalid, the other parts would stay in effect.' )
      
      scanner = TTV::Scanner.new
      @template = BallotStyleTemplate.make(:display_name => "test template")
      @ballot_config = DefaultBallot::BallotConfig.new( e1, @template)

      @pdf = create_pdf("Test Renderer")
      @ballot_config.setup(@pdf, p1)

      destination = nil
      
      @renderer = AbstractBallot::Renderer.new(e1, p1, @ballot_config, destination)
      
      
    end
    
    should "should be created " do

      assert @renderer
    end

    # This will look for all the Contests and Questions for this
    # Precinct and create Contest, Question and Container Flow objects
    # for each.
    should "initialize all the flow items" do
      @renderer.init_flow_items
      
      flow_items = @renderer.instance_variable_get(:@flow_items)
      
      # Should have 4 flow items
      # A Combo flow that contains a Header flow and a Contest flow
      # Two  Contest flows
      # And  a Question flow
      assert_equal 4, flow_items.size

      # First is a Combo Flow
      combo_flow = flow_items.first
      assert_instance_of DefaultBallot::FlowItem::Combo, combo_flow
      # This Combo Flow contains 2 other flow items
      combo_flow_items = combo_flow.instance_variable_get(:@flow_items)
      assert_equal 2, combo_flow_items.size
      # A Header Flow
      assert_instance_of DefaultBallot::FlowItem::Header, combo_flow_items.first
      # And a Contest Flow with a ref to the State Rep Contest
      contest_flow = combo_flow_items.last
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('State Rep'), contest
      
      # Next is a Contest flow with a ref to the Attorney General Contest
      contest_flow = flow_items[1]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Attorney General'), contest

      # A Contest flow with a ref to the Governor Contest
      contest_flow = flow_items[2]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Governor'), contest

      # A Question flow
      question_flow = flow_items.last
      assert_instance_of DefaultBallot::FlowItem::Question, question_flow
      question = question_flow.instance_variable_get(:@item)
      assert_equal Question.find_by_display_name('Dog Racing'), question

    end
    
    # Create a pdf with 2 pages. The first is blank, the second will
    # have a frame (tmp/ballot_render_frame.pdf) and a  header
    # (/tmp/ballot_render_header.pdf).
    # Also, draw a red border arounnd the leftmost, current column.
    should "start page " do
      
      # setup
      @renderer.init_flow_items
      @renderer.instance_variable_set(:@pagenum, 0)
      pdf = @ballot_config.instance_variable_get(:@pdf)
      @renderer.instance_variable_set(:@pdf, pdf)
      
      # call start_page
      flow_rect, columns, curr_column = @renderer.start_page

      # check that flow_rect for the entire page is correct, at least
      # within2 points
      assert_instance_of AbstractBallot::Rect, flow_rect
      # check_rect(rectangle, delta, width, height, top, left, bottom,right)
      assert check_rect(flow_rect, 2.0, 524.0, 568.0, 633.0, 26, 65, 550.0)
      
      # should have 3 columns on the page
      assert_instance_of AbstractBallot::Columns, columns
      # puts "TGD: columns = #{columns.inspect}"
      column_rects = columns.instance_variable_get(:@column_rects)
      assert_equal 3, column_rects.size
      
      # TODO: Add a test to make sure that columns do NOT overlap
      # col1.right <= col2.left,...
      
      # the current column should be the leftmost, first,  most column
      # puts "TGD: curr_column = #{curr_column.inspect}"
      assert_instance_of AbstractBallot::Rect, curr_column
      assert_equal curr_column, column_rects.first

      # draw a red line around the current column
      draw_rect(pdf, curr_column)
      draw_rect(pdf, flow_rect, '00ff00')
      draw_rect(pdf, column_rects.last)
      
      pdf.render_file("#{Rails.root}/tmp/renderer_start_page.pdf")                        
      
      util = TTV::Prawn::Util.new(pdf)
      # TODO: find out why 2 pages are generated here. Should only
      # have one?
      #assert_equal  "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\nQ\n", util.page_contents[0]
      
      #assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 684.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 670.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 684.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 670.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n1.000 0.000 0.000 SCN\n44.000 663.738 m\n218.667 663.738 l\nS\n44.000 663.738 m\n44.000 95.000 l\nS\n44.000 95.000 m\n218.667 95.000 l\nS\n218.667 95.000 m\n218.667 663.738 l\nS\n0.000 1.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n44.000 663.738 m\n44.000 95.000 l\nS\n44.000 95.000 m\n568.000 95.000 l\nS\n568.000 95.000 m\n568.000 663.738 l\nS\n1.000 0.000 0.000 SCN\n393.333 663.738 m\n568.000 663.738 l\nS\n393.333 663.738 m\n393.333 122.740 l\nS\n393.333 122.740 m\n568.000 122.740 l\nS\n568.000 122.740 m\n568.000 663.738 l\nS\nQ\n", util.page_contents[1]

    end
    
    # will draw the same page as start_page method above.
    # But, will add the continuation box that contains
    # "Thank you for voting. Please turn in you're ballot.
    should "end page " do
      
      # setup
      @renderer.init_flow_items
      @renderer.instance_variable_set(:@pagenum, 1)
      pdf = @ballot_config.instance_variable_get(:@pdf)
      @renderer.instance_variable_set(:@pdf, pdf)
      @renderer.start_page

      @renderer.end_page(true)

      # TODO: find out why 2 pages are generated here. Should only
      # have one?
      pdf.render_file("#{Rails.root}/tmp/renderer_end_page.pdf")                  

      util = TTV::Prawn::Util.new(pdf)
      #assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 684.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 670.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 684.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 670.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n\nBT\n80.5633333333333 653.458 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n71.6733333333333 642.588 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n44.000 635.998 m\n218.667 635.998 l\nS\n218.667 635.998 m\n218.667 663.738 l\nS\n44.000 635.998 m\n44.000 663.738 l\nS\nQ\n", util.page_contents[1]

    end
    
    # will draw the same page as start_page method above.
    # But, will add the continuation box in the upper left, under the
    # header, that contains "Continue voting next side".
    # Also, adds "Vote Boths Sides" centered on the top and bottom of
    # the page
    should "end page that is not the last page" do
      
      # setup
      @renderer.init_flow_items
      @renderer.instance_variable_set(:@pagenum, 1)
      pdf = @ballot_config.instance_variable_get(:@pdf)
      @renderer.instance_variable_set(:@pdf, pdf)
      @renderer.start_page
      
      # passing false will add text to prompt for voting on both sides
      @renderer.end_page(false)
      
      # TODO: find out why 2 pages are generated here. Should only
      # have one?
      pdf.render_file("#{Rails.root}/tmp/renderer_end_page_not_last.pdf")                  
      util = TTV::Prawn::Util.new(pdf)
      #assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 684.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 670.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 684.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 670.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n\nBT\n82.3283333333333 653.458 Td\n/F2.0 10 Tf\n<436f6e74696e756520766f74696e67> Tj\nET\n\n\nBT\n98.6783333333333 642.588 Td\n/F2.0 10 Tf\n<6e6578742073696465> Tj\nET\n\n210.667 647.738 m\n210.667 653.261 206.190 657.738 200.667 657.738 c\n195.144 657.738 190.667 653.261 190.667 647.738 c\n190.667 642.215 195.144 637.738 200.667 637.738 c\n206.190 637.738 210.667 642.215 210.667 647.738 c\n200.667 647.738 m\n0.000 0.000 0.000 scn\nb\n1.000 1.000 1.000 SCN\n1 J\n2 w\n194.667 647.738 m\n206.667 647.738 l\nS\n200.667 653.738 m\n206.667 647.738 l\n200.667 641.738 l\nS\n0.75 w\n0.000 0.000 0.000 SCN\n44.000 635.998 m\n218.667 635.998 l\nS\n218.667 635.998 m\n218.667 663.738 l\nS\n44.000 635.998 m\n44.000 663.738 l\nS\n\nBT\n252.90653125 751.808 Td\n/F2.0 14 Tf\n[<56> 74.21875 <6f746520426f7468205369646573>] TJ\nET\n\n\nBT\n252.90653125 39.808 Td\n/F2.0 14 Tf\n[<56> 74.21875 <6f746520426f7468205369646573>] TJ\nET\n\nQ\n", util.page_contents[1]

    end
    
    # TODO
    should "fit the flow item in any column on the current page " do
      
    end

    # render the page including all the Contest flow objects in the
    # middle column
    should "render everything" do
      # setup 
      @renderer.init_flow_items
      pdf = @ballot_config.instance_variable_get(:@pdf)
      @renderer.instance_variable_set(:@pdf, pdf)

      
      @renderer.render_everything
      
      # TODO: find out why 2 pages are generated here. Should only
      # have one?
      pdf.render_file("#{Rails.root}/tmp/renderer_render_everything.pdf")                  
      util = TTV::Prawn::Util.new(pdf)
      # assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 684.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 670.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 684.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 670.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n\nBT\n47.0 653.458 Td\n/F2.0 10 Tf\n<44697374726963742030> Tj\nET\n\n0.5 w\n44.000 648.868 m\n218.667 648.868 l\nS\n218.667 648.868 m\n218.667 663.738 l\nS\n44.000 648.868 m\n44.000 663.738 l\nS\n\nBT\n47.0 638.588 Td\n/F2.0 10 Tf\n<537461746520526570> Tj\nET\n\n\nBT\n47.0 623.718 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 588.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 590.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n108.0 580.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 560.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 562.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n108.0 552.04 Td\nET\n\n\nBT\n108.0 541.36 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 504.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 506.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n108.0 496.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 476.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 478.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n108.000 459.320 m\n212.667 459.320 l\nS\n[] 0 d\n0.5 w\n44.000 453.320 m\n218.667 453.320 l\nS\n218.667 453.320 m\n218.667 648.868 l\nS\n44.000 453.320 m\n44.000 648.868 l\nS\n\nBT\n47.0 443.04 Td\n/F2.0 10 Tf\n<4174746f726e65792047656e6572616c> Tj\nET\n\n\nBT\n47.0 428.17 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 392.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 394.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n108.0 384.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 364.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 366.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n108.0 356.04 Td\nET\n\n\nBT\n108.0 345.36 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 308.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 310.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n108.0 300.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n80.000 280.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n108.0 282.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n108.000 263.320 m\n212.667 263.320 l\nS\n[] 0 d\n0.5 w\n44.000 257.320 m\n218.667 257.320 l\nS\n218.667 257.320 m\n218.667 453.320 l\nS\n44.000 257.320 m\n44.000 453.320 l\nS\n\nBT\n221.666666666667 653.458 Td\n/F2.0 10 Tf\n<476f7665726e6f72> Tj\nET\n\n\nBT\n221.666666666667 638.588 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 616.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 618.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 608.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 588.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 590.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 580.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 560.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 562.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 552.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 532.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 534.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 515.320 m\n387.333 515.320 l\nS\n[] 0 d\n0.5 w\n218.667 509.320 m\n393.333 509.320 l\nS\n393.333 509.320 m\n393.333 663.738 l\nS\n218.667 509.320 m\n218.667 663.738 l\nS\n\nBT\n255.23 499.04 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n246.34 488.17 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n218.667 481.580 m\n393.333 481.580 l\nS\n393.333 481.580 m\n393.333 509.320 l\nS\n218.667 481.580 m\n218.667 509.320 l\nS\nQ\n", util.page_contents[1]

    end

    # render the page including all the Contest flow objects in the
    # middle column. Same as above but don't need setup.
    should "render" do
      @renderer.render

      # get the pdf from the renderer this time
      # cuz this method creates it.
      # all the above methods assumed this render method was already
      # invoked
      pdf = @renderer.instance_variable_get(:@pdf)
      
      pdf.render_file("#{Rails.root}/tmp/renderer_render.pdf")                  
      util = TTV::Prawn::Util.new(pdf)

      # first page is the contests
      # TODO: removed to for DC Ballots. Evaluate if this test is
        # needed?
      # assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 684.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 670.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 684.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 670.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n\nBT\n47.0 653.458 Td\n/F2.0 10 Tf\n<44697374726963742030> Tj\nET\n\n0.5 w\n44.000 648.868 m\n218.667 648.868 l\nS\n218.667 648.868 m\n218.667 663.738 l\nS\n44.000 648.868 m\n44.000 663.738 l\nS\n\nBT\n47.0 638.588 Td\n/F2.0 10 Tf\n<537461746520526570> Tj\nET\n\n\nBT\n47.0 623.718 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n68.000 603.128 22.000 10.000 re\nS\n\nBT\n93.0 605.848 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 594.978 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n68.000 575.388 22.000 10.000 re\nS\n\nBT\n93.0 578.108 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 567.238 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n68.000 547.648 22.000 10.000 re\nS\n\nBT\n93.0 550.368 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n93.0 539.498 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n68.000 525.908 22.000 10.000 re\nS\n\nBT\n93.0 528.628 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n94.000 503.908 m\n212.667 503.908 l\nS\n[] 0 d\n0.5 w\n44.000 481.038 m\n218.667 481.038 l\nS\n218.667 481.038 m\n218.667 648.868 l\nS\n44.000 481.038 m\n44.000 648.868 l\nS\n\nBT\n47.0 470.758 Td\n/F2.0 10 Tf\n<4174746f726e65792047656e6572616c> Tj\nET\n\n\nBT\n47.0 455.888 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n68.000 435.298 22.000 10.000 re\nS\n\nBT\n93.0 438.018 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 427.148 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n68.000 407.558 22.000 10.000 re\nS\n\nBT\n93.0 410.278 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 399.408 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n68.000 379.818 22.000 10.000 re\nS\n\nBT\n93.0 382.538 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n93.0 371.668 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n68.000 358.078 22.000 10.000 re\nS\n\nBT\n93.0 360.798 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n94.000 336.078 m\n212.667 336.078 l\nS\n[] 0 d\n0.5 w\n44.000 313.208 m\n218.667 313.208 l\nS\n218.667 313.208 m\n218.667 481.038 l\nS\n44.000 313.208 m\n44.000 481.038 l\nS\n\nBT\n47.0 302.928 Td\n/F2.0 10 Tf\n<476f7665726e6f72> Tj\nET\n\n\nBT\n47.0 288.058 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n68.000 267.468 22.000 10.000 re\nS\n\nBT\n93.0 270.188 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 259.318 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n68.000 239.728 22.000 10.000 re\nS\n\nBT\n93.0 242.448 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 231.578 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n68.000 211.988 22.000 10.000 re\nS\n\nBT\n93.0 214.708 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n93.0 203.838 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n68.000 190.248 22.000 10.000 re\nS\n\nBT\n93.0 192.968 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n94.000 168.248 m\n212.667 168.248 l\nS\n[] 0 d\n0.5 w\n44.000 145.378 m\n218.667 145.378 l\nS\n218.667 145.378 m\n218.667 313.208 l\nS\n44.000 145.378 m\n44.000 313.208 l\nS\n\nBT\n220.666666666667 653.458 Td\n/F2.0 10 Tf\n<446f6720526163696e67> Tj\nET\n\n\nBT\n220.666666666667 638.588 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520796573206f72206e6f>] TJ\nET\n\n\nBT\n220.666666666667 620.718 Td\n/F3.0 10 Tf\n<546869732070726f706f736564206c617720776f756c642070726f686962697420616e7920646f6720726163696e67206f7220726163696e67206d656574696e6720696e> Tj\nET\n\n\nBT\n220.666666666667 609.038 Td\n/F3.0 10 Tf\n<4d61737361636875736574747320776865726520616e7920666f726d206f662062657474696e67206f72207761676572696e67206f6e20746865207370656564206f72206162696c697479> Tj\nET\n\n\nBT\n220.666666666667 597.358 Td\n/F3.0 10 Tf\n<6f6620646f6773206f63637572732e2054686520537461746520526163696e6720436f6d6d697373696f6e20776f756c642062652070726f686962697465642066726f6d> Tj\nET\n\n\nBT\n220.666666666667 585.678 Td\n/F3.0 10 Tf\n<616363657074696e67206f7220617070726f76696e6720616e79206170706c69636174696f6e206f72207265717565737420666f7220726163696e6720646174657320666f7220646f67> Tj\nET\n\n\nBT\n220.666666666667 573.998 Td\n/F3.0 10 Tf\n<726163696e672e20416e7920706572736f6e2076696f6c6174696e67207468652070726f706f736564206c617720636f756c6420626520726571756972656420746f20706179206120636976696c> Tj\nET\n\n\nBT\n220.666666666667 562.318 Td\n/F3.0 10 Tf\n<70656e616c7479206f66206e6f74206c657373207468616e202432302c30303020746f2074686520436f6d6d697373696f6e2e205468652070656e616c747920776f756c64206265> Tj\nET\n\n\nBT\n220.666666666667 550.638 Td\n/F3.0 10 Tf\n<7573656420666f722074686520436f6d6d697373696f6e27732061646d696e69737472617469766520707572706f7365732c207375626a65637420746f20617070726f7072696174696f6e> Tj\nET\n\n\nBT\n220.666666666667 538.958 Td\n/F3.0 10 Tf\n<627920746865207374617465204c656769736c61747572652e20416c6c206578697374696e67207061727473206f66207468652063686170746572206f662074686520737461746527732047656e6572616c> Tj\nET\n\n\nBT\n220.666666666667 527.278 Td\n/F3.0 10 Tf\n<4c61777320636f6e6365726e696e6720646f6720616e6420686f72736520726163696e67206d656574696e677320776f756c6420626520696e746572707265746564206173206966> Tj\nET\n\n\nBT\n220.666666666667 515.598 Td\n/F3.0 10 Tf\n<7468657920646964206e6f7420726566657220746f20646f67732e205468657365206368616e67657320776f756c642074616b6520656666656374204a616e7561727920312c20323031302e> Tj\nET\n\n\nBT\n220.666666666667 503.918 Td\n/F3.0 10 Tf\n<5468652070726f706f736564206c617720737461746573207468617420696620616e79206f66206974732070617274732077657265206465636c6172656420696e76616c69642c20746865> Tj\nET\n\n\nBT\n220.666666666667 492.238 Td\n/F3.0 10 Tf\n<6f7468657220706172747320776f756c64207374617920696e206566666563742e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 448.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 450.72 Td\n/F3.0 10 Tf\n<596573> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 420.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 422.72 Td\n/F3.0 10 Tf\n<4e6f> Tj\nET\n\n0.5 w\n0.5 w\n218.667 416.320 m\n568.000 416.320 l\nS\n568.000 416.320 m\n568.000 663.738 l\nS\n218.667 416.320 m\n218.667 663.738 l\nS\n\nBT\n342.563333333333 406.04 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n333.673333333333 395.17 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n218.667 388.580 m\n568.000 388.580 l\nS\n568.000 388.580 m\n568.000 416.320 l\nS\n218.667 388.580 m\n218.667 416.320 l\nS\nQ\n", util.page_contents[0]

      # second page is the question 
      #assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 684.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 670.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 684.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 670.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 663.738 m\n568.000 663.738 l\nS\n\nBT\n47.0 653.458 Td\n/F2.0 10 Tf\n<44697374726963742030> Tj\nET\n\n0.5 w\n44.000 648.868 m\n218.667 648.868 l\nS\n218.667 648.868 m\n218.667 663.738 l\nS\n44.000 648.868 m\n44.000 663.738 l\nS\n\nBT\n47.0 638.588 Td\n/F2.0 10 Tf\n<537461746520526570> Tj\nET\n\n\nBT\n47.0 623.718 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n68.000 603.128 22.000 10.000 re\nS\n\nBT\n93.0 605.848 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 594.978 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n68.000 575.388 22.000 10.000 re\nS\n\nBT\n93.0 578.108 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 567.238 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n68.000 547.648 22.000 10.000 re\nS\n\nBT\n93.0 550.368 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n93.0 539.498 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n68.000 525.908 22.000 10.000 re\nS\n\nBT\n93.0 528.628 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n94.000 503.908 m\n212.667 503.908 l\nS\n[] 0 d\n0.5 w\n44.000 481.038 m\n218.667 481.038 l\nS\n218.667 481.038 m\n218.667 648.868 l\nS\n44.000 481.038 m\n44.000 648.868 l\nS\n\nBT\n47.0 470.758 Td\n/F2.0 10 Tf\n<4174746f726e65792047656e6572616c> Tj\nET\n\n\nBT\n47.0 455.888 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n68.000 435.298 22.000 10.000 re\nS\n\nBT\n93.0 438.018 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 427.148 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n68.000 407.558 22.000 10.000 re\nS\n\nBT\n93.0 410.278 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 399.408 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n68.000 379.818 22.000 10.000 re\nS\n\nBT\n93.0 382.538 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n93.0 371.668 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n68.000 358.078 22.000 10.000 re\nS\n\nBT\n93.0 360.798 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n94.000 336.078 m\n212.667 336.078 l\nS\n[] 0 d\n0.5 w\n44.000 313.208 m\n218.667 313.208 l\nS\n218.667 313.208 m\n218.667 481.038 l\nS\n44.000 313.208 m\n44.000 481.038 l\nS\n\nBT\n47.0 302.928 Td\n/F2.0 10 Tf\n<476f7665726e6f72> Tj\nET\n\n\nBT\n47.0 288.058 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n68.000 267.468 22.000 10.000 re\nS\n\nBT\n93.0 270.188 Td\n/F2.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 259.318 Td\n/F2.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n68.000 239.728 22.000 10.000 re\nS\n\nBT\n93.0 242.448 Td\n/F2.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n93.0 231.578 Td\n/F2.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n68.000 211.988 22.000 10.000 re\nS\n\nBT\n93.0 214.708 Td\n/F2.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n93.0 203.838 Td\n/F2.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n68.000 190.248 22.000 10.000 re\nS\n\nBT\n93.0 192.968 Td\n/F2.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n94.000 168.248 m\n212.667 168.248 l\nS\n[] 0 d\n0.5 w\n44.000 145.378 m\n218.667 145.378 l\nS\n218.667 145.378 m\n218.667 313.208 l\nS\n44.000 145.378 m\n44.000 313.208 l\nS\n\nBT\n220.666666666667 653.458 Td\n/F2.0 10 Tf\n<446f6720526163696e67> Tj\nET\n\n\nBT\n220.666666666667 638.588 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520796573206f72206e6f>] TJ\nET\n\n\nBT\n220.666666666667 620.718 Td\n/F3.0 10 Tf\n<546869732070726f706f736564206c617720776f756c642070726f686962697420616e7920646f6720726163696e67206f7220726163696e67206d656574696e6720696e> Tj\nET\n\n\nBT\n220.666666666667 609.038 Td\n/F3.0 10 Tf\n<4d61737361636875736574747320776865726520616e7920666f726d206f662062657474696e67206f72207761676572696e67206f6e20746865207370656564206f72206162696c697479> Tj\nET\n\n\nBT\n220.666666666667 597.358 Td\n/F3.0 10 Tf\n<6f6620646f6773206f63637572732e2054686520537461746520526163696e6720436f6d6d697373696f6e20776f756c642062652070726f686962697465642066726f6d> Tj\nET\n\n\nBT\n220.666666666667 585.678 Td\n/F3.0 10 Tf\n<616363657074696e67206f7220617070726f76696e6720616e79206170706c69636174696f6e206f72207265717565737420666f7220726163696e6720646174657320666f7220646f67> Tj\nET\n\n\nBT\n220.666666666667 573.998 Td\n/F3.0 10 Tf\n<726163696e672e20416e7920706572736f6e2076696f6c6174696e67207468652070726f706f736564206c617720636f756c6420626520726571756972656420746f20706179206120636976696c> Tj\nET\n\n\nBT\n220.666666666667 562.318 Td\n/F3.0 10 Tf\n<70656e616c7479206f66206e6f74206c657373207468616e202432302c30303020746f2074686520436f6d6d697373696f6e2e205468652070656e616c747920776f756c64206265> Tj\nET\n\n\nBT\n220.666666666667 550.638 Td\n/F3.0 10 Tf\n<7573656420666f722074686520436f6d6d697373696f6e27732061646d696e69737472617469766520707572706f7365732c207375626a65637420746f20617070726f7072696174696f6e> Tj\nET\n\n\nBT\n220.666666666667 538.958 Td\n/F3.0 10 Tf\n<627920746865207374617465204c656769736c61747572652e20416c6c206578697374696e67207061727473206f66207468652063686170746572206f662074686520737461746527732047656e6572616c> Tj\nET\n\n\nBT\n220.666666666667 527.278 Td\n/F3.0 10 Tf\n<4c61777320636f6e6365726e696e6720646f6720616e6420686f72736520726163696e67206d656574696e677320776f756c6420626520696e746572707265746564206173206966> Tj\nET\n\n\nBT\n220.666666666667 515.598 Td\n/F3.0 10 Tf\n<7468657920646964206e6f7420726566657220746f20646f67732e205468657365206368616e67657320776f756c642074616b6520656666656374204a616e7561727920312c20323031302e> Tj\nET\n\n\nBT\n220.666666666667 503.918 Td\n/F3.0 10 Tf\n<5468652070726f706f736564206c617720737461746573207468617420696620616e79206f66206974732070617274732077657265206465636c6172656420696e76616c69642c20746865> Tj\nET\n\n\nBT\n220.666666666667 492.238 Td\n/F3.0 10 Tf\n<6f7468657220706172747320776f756c64207374617920696e206566666563742e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 448.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 450.72 Td\n/F3.0 10 Tf\n<596573> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 420.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 422.72 Td\n/F3.0 10 Tf\n<4e6f> Tj\nET\n\n0.5 w\n0.5 w\n218.667 416.320 m\n568.000 416.320 l\nS\n568.000 416.320 m\n568.000 663.738 l\nS\n218.667 416.320 m\n218.667 663.738 l\nS\n\nBT\n342.563333333333 406.04 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n333.673333333333 395.17 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n218.667 388.580 m\n568.000 388.580 l\nS\n568.000 388.580 m\n568.000 416.320 l\nS\n218.667 388.580 m\n218.667 416.320 l\nS\nQ\n", util.page_contents.last

    end
  end # end AbstractBallot::Renderer context

  def check_rect(rect, delta, w, h, top, left, bottom, right)
    assert_equal  w, rect.width
    assert_in_delta  h, rect.height, delta
    
    assert_in_delta  top, rect.top, delta
    assert_equal  left, rect.left
    assert_equal  bottom, rect.bottom
    assert_in_delta  right, rect.right, delta
    
    true
  end
  
  def draw_rect(pdf, rect, color='ff0000')
    pdf.stroke_color(color) #"FFFFFF"
    pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
    pdf.stroke_line([rect.left, rect.top], [rect.left, rect.bottom])
    pdf.stroke_line([rect.left, rect.bottom], [rect.right, rect.bottom])
    pdf.stroke_line([rect.right, rect.bottom], [rect.right, rect.top])
    
    # pdf.rectangle([rect.left, rect.top], rect.width, rect.height)
  end
end 
