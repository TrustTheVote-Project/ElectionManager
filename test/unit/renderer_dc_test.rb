require 'test_helper'
require 'ballots/dc/ballot_config.rb'

class RendererTest < ActiveSupport::TestCase
  
  context "AbstractBallot::Renderer " do
    
    setup do
      setup_ballot
    end
    
    should "should be created " do
      assert @renderer
    end

    # This will look for all the Contests and Questions for this
    # Precinct and create Contest, Question and Container Flow objects
    # for each.
    should "initialize all the flow items" do
      @renderer.instance_variable_set(:@flow_items,::DefaultBallot::FlowItem.init_flow_items(@pdf, @election, @prec_split, @template))
      
      flow_items = @renderer.instance_variable_get(:@flow_items)
      
      # Should have 7 flow items
      # A Combo flow that contains a Header flow and a Contest flow
      # 6 Contest flows
      # And a Question flow
      assert_equal 7, flow_items.size

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
      assert_equal Contest.find_by_display_name('Contest 1'), contest
      
      # Next is a Contest flow with a ref to the Attorney General Contest
      contest_flow = flow_items[1]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 2'), contest

      # A Contest flow with a ref to the Governor Contest
      contest_flow = flow_items[2]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 3'), contest

      # A Question flow
      #       question_flow = flow_items.last
      #       assert_instance_of DefaultBallot::FlowItem::Question, question_flow
      #       question = question_flow.instance_variable_get(:@item)
      #       assert_equal Question.find_by_display_name('Dog Racing'), question

    end

    #     # render the page including all the Contest flow objects in the
    #     # middle column
    #     should "render everything" do
    #       # setup 
    #       @renderer.init_flow_items
    #       pdf = @ballot_config.instance_variable_get(:@pdf)
    #       @renderer.instance_variable_set(:@pdf, pdf)

    
    #       @renderer.render_everything
    
    #       # TODO: find out why 2 pages are generated here. Should only
    #       # have one?
    #       pdf.render_file("#{Rails.root}/tmp/dc_render_everything.pdf")                  
    #       util = TTV::Prawn::Util.new(pdf)
    #     end

    # render the page including all the Contest flow objects in the
    # middle column. Same as above but don't need setup.
    should "render" do
      @renderer.render

      # get the pdf from the renderer this time
      # cuz this method creates it.
      # all the above methods assumed this render method was already
      # invoked
      pdf = @renderer.instance_variable_get(:@pdf)
      
      pdf.render_file("#{Rails.root}/tmp/dc_render.pdf")                  
      util = TTV::Prawn::Util.new(pdf)

      # first page is the contests

      # second page is the question 

    end
  end # end AbstractBallot::Renderer context
end 
