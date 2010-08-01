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
      e1.start_date = DateTime.now

      # OK, now we have a precinct that contains districts 0 to 3
      # And an election that has districts 0 and 1
      
      # Create 3 contests for this election
      pos = 0;
      ["State Rep", "Attorney General","Governor"].each do |contest_name|
        add_contest(contest_name, e1, pos)
        pos += 1
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
      pdf.render_file("#{Rails.root}/tmp/renderer_render.pdf")                  
    end
  end # end AbstractBallot::Renderer context
  
  def add_contest(name, election, pos)
    contest = Contest.new(:display_name => name)
    contest.voting_method = VotingMethod::WINNER_TAKE_ALL
    contest.district = election.district_set.districts.first
    contest.election = election
    contest.position = pos += 1
    contest.save
    #      puts "TGD: Contest created : contest = #{contest.inspect}"
  end
  
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
    pdf.stroke_color color #"FFFFFF"
    pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
    pdf.stroke_line([rect.left, rect.top], [rect.left, rect.bottom])
    pdf.stroke_line([rect.left, rect.bottom], [rect.right, rect.bottom])
    pdf.stroke_line([rect.right, rect.bottom], [rect.right, rect.top])
    
    # pdf.rectangle([rect.left, rect.top], rect.width, rect.height)
  end
end 
