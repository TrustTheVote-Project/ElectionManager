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
      
      scanner = TTV::Scanner.new
      @ballot_config = DefaultBallot::BallotConfig.new('default', 'en', e1, scanner, "missing")
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
      
      # Should have 3 flow items
      # A Combo flow that contains a Header flow and a Contest flow
      # A Contest flow
      # And another Contest flow
      assert_equal 3, flow_items.size

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

      # Finally, a Contest flow with a ref to the Governor Contest
      contest_flow = flow_items.last
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Governor'), contest

    end
    
    # Create a pdf with 2 pages. The first is blank, the second will
    # have a frame (tmp/ballot_render_frame.pdf) and a  header
    # (/tmp/ballot_render_header.pdf).
    # Also, draw a red border arounnd the leftmost, current column.
    should "start page " do
      
      # setup
      @renderer.init_flow_items
      @renderer.instance_variable_set(:@pagenum, 1)
      pdf = @ballot_config.instance_variable_get(:@pdf)
      @renderer.instance_variable_set(:@pdf, pdf)
      
      # call start_page
      flow_rect, columns, curr_column = @renderer.start_page

      # check that flow_rect for the entire page is correct, at least
      # within2 points
      assert_instance_of AbstractBallot::Rect, flow_rect
      # check_rect(rectangle, delta, width, height, top, left, bottom,right)
      assert check_rect(flow_rect, 2.0, 524.0, 637.7, 668.7, 26, 30, 550.0)
      
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
      
      util = TTV::Prawn::Util.new(pdf)
      # TODO: find out why 2 pages are generated here. Should only
      # have one?
      assert_equal  "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n", util.page_contents[0]
      
      assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 719.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 705.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 719.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 705.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 698.738 m\n568.000 698.738 l\nS\n1.000 0.000 0.000 SCN\n44.000 698.738 m\n218.667 698.738 l\nS\n44.000 698.738 m\n44.000 60.000 l\nS\n44.000 60.000 m\n218.667 60.000 l\nS\n218.667 60.000 m\n218.667 698.738 l\nS\n", util.page_contents[1]
     
      pdf.render_file("#{Rails.root}/tmp/renderer_start_page.pdf")                  
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
      util = TTV::Prawn::Util.new(pdf)
      assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 719.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 705.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 719.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 705.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 698.738 m\n568.000 698.738 l\nS\n\nBT\n80.5633333333333 688.458 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n71.6733333333333 677.588 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n44.000 670.998 m\n218.667 670.998 l\nS\n218.667 670.998 m\n218.667 698.738 l\nS\n44.000 670.998 m\n44.000 698.738 l\nS\n", util.page_contents[1]

      pdf.render_file("#{Rails.root}/tmp/renderer_end_page.pdf")                  
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
      util = TTV::Prawn::Util.new(pdf)
      assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 719.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 705.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 719.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 705.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 698.738 m\n568.000 698.738 l\nS\n\nBT\n82.3283333333333 688.458 Td\n/F2.0 10 Tf\n<436f6e74696e756520766f74696e67> Tj\nET\n\n\nBT\n98.6783333333333 677.588 Td\n/F2.0 10 Tf\n<6e6578742073696465> Tj\nET\n\n210.667 682.738 m\n210.667 688.261 206.190 692.738 200.667 692.738 c\n195.144 692.738 190.667 688.261 190.667 682.738 c\n190.667 677.215 195.144 672.738 200.667 672.738 c\n206.190 672.738 210.667 677.215 210.667 682.738 c\n200.667 682.738 m\n0.000 0.000 0.000 scn\nb\n1.000 1.000 1.000 SCN\n1 J\n2 w\n194.667 682.738 m\n206.667 682.738 l\nS\n200.667 688.738 m\n206.667 682.738 l\n200.667 676.738 l\nS\n0.75 w\n0.000 0.000 0.000 SCN\n44.000 670.998 m\n218.667 670.998 l\nS\n218.667 670.998 m\n218.667 698.738 l\nS\n44.000 670.998 m\n44.000 698.738 l\nS\n\nBT\n252.90653125 751.808 Td\n/F2.0 14 Tf\n[<56> 74.21875 <6f746520426f7468205369646573>] TJ\nET\n\n\nBT\n252.90653125 39.808 Td\n/F2.0 14 Tf\n[<56> 74.21875 <6f746520426f7468205369646573>] TJ\nET\n\n", util.page_contents[1]

      pdf.render_file("#{Rails.root}/tmp/renderer_end_page_not_last.pdf")                  
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
      util = TTV::Prawn::Util.new(pdf)
      assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 719.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 705.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 719.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 705.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 698.738 m\n568.000 698.738 l\nS\n0.5 w\n\nBT\n221.666666666667 688.458 Td\n/F2.0 10 Tf\n<44697374726963742030> Tj\nET\n\n0.5 w\n218.667 683.868 m\n393.333 683.868 l\nS\n393.333 683.868 m\n393.333 698.738 l\nS\n218.667 683.868 m\n218.667 698.738 l\nS\n\nBT\n221.666666666667 673.588 Td\n/F2.0 10 Tf\n<537461746520526570> Tj\nET\n\n\nBT\n221.666666666667 658.718 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 616.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 618.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 608.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 588.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 590.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 580.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 560.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 562.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 552.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 532.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 534.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 515.320 m\n387.333 515.320 l\nS\n[] 0 d\n0.5 w\n218.667 509.320 m\n393.333 509.320 l\nS\n393.333 509.320 m\n393.333 683.868 l\nS\n218.667 509.320 m\n218.667 683.868 l\nS\n\nBT\n221.666666666667 499.04 Td\n/F2.0 10 Tf\n<4174746f726e65792047656e6572616c> Tj\nET\n\n\nBT\n221.666666666667 484.17 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 448.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 450.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 440.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 420.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 422.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 412.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 392.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 394.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 384.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 364.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 366.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 347.320 m\n387.333 347.320 l\nS\n[] 0 d\n0.5 w\n218.667 341.320 m\n393.333 341.320 l\nS\n393.333 341.320 m\n393.333 509.320 l\nS\n218.667 341.320 m\n218.667 509.320 l\nS\n\nBT\n221.666666666667 331.04 Td\n/F2.0 10 Tf\n<476f7665726e6f72> Tj\nET\n\n\nBT\n221.666666666667 316.17 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 280.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 282.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 272.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 252.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 254.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 244.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 224.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 226.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 216.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 196.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 198.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 179.320 m\n387.333 179.320 l\nS\n[] 0 d\n0.5 w\n218.667 173.320 m\n393.333 173.320 l\nS\n393.333 173.320 m\n393.333 341.320 l\nS\n218.667 173.320 m\n218.667 341.320 l\nS\n\nBT\n255.23 163.04 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n246.34 152.17 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n218.667 145.580 m\n393.333 145.580 l\nS\n393.333 145.580 m\n393.333 173.320 l\nS\n218.667 145.580 m\n218.667 173.320 l\nS\n", util.page_contents[1]
      pdf.render_file("#{Rails.root}/tmp/renderer_render_everything.pdf")                  
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

      util = TTV::Prawn::Util.new(pdf)
      #assert_equal 'foo', util.page_contents[0]
      assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n\nBT\n52 719.536 Td\n/F2.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n52 705.405 Td\n/F2.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n365.333 719.536 Td\n/F2.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n368.57 705.405 Td\n/F2.0 13 Tf\n<50726563696e742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n44.000 698.738 m\n568.000 698.738 l\nS\n0.5 w\n\nBT\n221.666666666667 688.458 Td\n/F2.0 10 Tf\n<44697374726963742030> Tj\nET\n\n0.5 w\n218.667 683.868 m\n393.333 683.868 l\nS\n393.333 683.868 m\n393.333 698.738 l\nS\n218.667 683.868 m\n218.667 698.738 l\nS\n\nBT\n221.666666666667 673.588 Td\n/F2.0 10 Tf\n<537461746520526570> Tj\nET\n\n\nBT\n221.666666666667 658.718 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 616.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 618.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 608.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 588.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 590.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 580.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 560.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 562.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 552.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 532.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 534.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 515.320 m\n387.333 515.320 l\nS\n[] 0 d\n0.5 w\n218.667 509.320 m\n393.333 509.320 l\nS\n393.333 509.320 m\n393.333 683.868 l\nS\n218.667 509.320 m\n218.667 683.868 l\nS\n\nBT\n221.666666666667 499.04 Td\n/F2.0 10 Tf\n<4174746f726e65792047656e6572616c> Tj\nET\n\n\nBT\n221.666666666667 484.17 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 448.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 450.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 440.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 420.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 422.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 412.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 392.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 394.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 384.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 364.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 366.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 347.320 m\n387.333 347.320 l\nS\n[] 0 d\n0.5 w\n218.667 341.320 m\n393.333 341.320 l\nS\n393.333 341.320 m\n393.333 509.320 l\nS\n218.667 341.320 m\n218.667 509.320 l\nS\n\nBT\n221.666666666667 331.04 Td\n/F2.0 10 Tf\n<476f7665726e6f72> Tj\nET\n\n\nBT\n221.666666666667 316.17 Td\n/F2.0 10 Tf\n[<56> 74.21875 <6f746520666f722031>] TJ\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 280.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 282.72 Td\n/F3.0 10 Tf\n<64656d6f637261745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 272.04 Td\n/F3.0 10 Tf\n<44656d6f63726174> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 252.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 254.72 Td\n/F3.0 10 Tf\n<696e646570656e64656e745f43616e646964617465> Tj\nET\n\n\nBT\n268.0 244.04 Td\n/F3.0 10 Tf\n<496e646570656e64656e74> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 224.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 226.72 Td\n/F3.0 10 Tf\n<72657075626c6963616e5f43616e646964617465> Tj\nET\n\n\nBT\n268.0 216.04 Td\n/F3.0 10 Tf\n<52657075626c6963616e> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 196.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 198.72 Td\n/F3.0 10 Tf\n<6f722077726974652d696e> Tj\nET\n\n[1 1] 0 d\n268.000 179.320 m\n387.333 179.320 l\nS\n[] 0 d\n0.5 w\n218.667 173.320 m\n393.333 173.320 l\nS\n393.333 173.320 m\n393.333 341.320 l\nS\n218.667 173.320 m\n218.667 341.320 l\nS\n\nBT\n255.23 163.04 Td\n/F2.0 10 Tf\n<5468616e6b20796f7520666f7220766f74696e672e> Tj\nET\n\n\nBT\n246.34 152.17 Td\n/F2.0 10 Tf\n<506c65617365207475726e20696e20796f75722062616c6c6f74> Tj\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n218.667 145.580 m\n393.333 145.580 l\nS\n393.333 145.580 m\n393.333 173.320 l\nS\n218.667 145.580 m\n218.667 173.320 l\nS\n", util.page_contents[0]
      
      pdf.render_file("#{Rails.root}/tmp/renderer_render.pdf")                  
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
  
  def draw_rect(pdf, rect)
    pdf.stroke_color 'ff0000' #"FFFFFF"
    pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
    pdf.stroke_line([rect.left, rect.top], [rect.left, rect.bottom])
    pdf.stroke_line([rect.left, rect.bottom], [rect.right, rect.bottom])
    pdf.stroke_line([rect.right, rect.bottom], [rect.right, rect.top])
    
    # pdf.rectangle([rect.left, rect.top], rect.width, rect.height)
  end
end 
