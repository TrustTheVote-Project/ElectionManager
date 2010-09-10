require 'test_helper'
require 'ballots/default/flow_item.rb'

class FlowItemsTest < ActiveSupport::TestCase
  
  context "FlowItems" do
    
    setup do
      setup_ballot

    end 
    should "get the Content flow item for Contests" do
      assert_instance_of DefaultBallot::FlowItem::Contest, ::DefaultBallot::FlowItem.create_flow_item(@pdf, Contest.new)
    end
    
    should "get the Question flow item for Questions" do
      assert_instance_of DefaultBallot::FlowItem::Question, ::DefaultBallot::FlowItem.create_flow_item(@pdf, Question.new)
    end

    should "get the Header flow item for Strings" do
      assert_instance_of DefaultBallot::FlowItem::Header, ::DefaultBallot::FlowItem.create_flow_item(@pdf, "Header Content String")
    end
    
    # This will look for all the Contests and Questions for this
    # Precinct and create Contest, Question and Container Flow objects
    # for each.
    should "initialize all the flow items" do
      flow_items = ::DefaultBallot::FlowItem.init_flow_items(@pdf, @election, @prec_split, @template)
      
      #flow_items = @renderer.instance_variable_get(:@flow_items)
      
      # Should have 4 flow items
      # A Combo flow that contains a Header flow and a Contest flow
      # Two  Contest flows
      # And  a Question flow
      assert_equal 7, flow_items.size

      # First is a Combo Flow
      combo_flow = flow_items.first
      assert_instance_of DefaultBallot::FlowItem::Combo, combo_flow
      # This Combo Flow contains 2 other flow items
      combo_flow_items = combo_flow.instance_variable_get(:@flow_items)
      assert_equal 2, combo_flow_items.size
      # A Header Flow
      assert_instance_of DefaultBallot::FlowItem::Header, combo_flow_items.first
      # And a Contest Flow with a ref to the Contest 1 Contest
      contest_flow = combo_flow_items.last
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 1'), contest
      
      # Next is a Contest flow with a ref to the Contest 2 Contest
      contest_flow = flow_items[1]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 2'), contest

      # A Contest flow with a ref to the Contest 3 Contest
      contest_flow = flow_items[2]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 3'), contest

      # A Question flow
      question_flow = flow_items.last
      assert_instance_of DefaultBallot::FlowItem::Question, question_flow
      question = question_flow.instance_variable_get(:@item)
      assert_equal Question.find_by_display_name('Dog Racing'), question

    end

    
  end
end

