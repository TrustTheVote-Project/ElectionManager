require 'test_helper'
require 'ballots/default/header_flow'

class QuestionFlowTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Question" do
    setup do
      
      create_ballot_config(true)

      
      #       @question = Question.make(:display_name => "Dog Racing",
      #                                 :election => election,
      #                                 :requesting_district => District.make(:display_name => "District 1"),
      #                                 :question => 'This proposed law would ')
      
      # create a flow rect/frame to enclose all the columns
      flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
      # draw aqua outline/stroke around the flow rectangle
      TTV::Prawn::Util.stroke_rect(@pdf, flow_rect, "#ffffff")
      
      # create 3 columns of equal width within the frame
      @columns = AbstractBallot::Columns.new(3, flow_rect)
      
      # get the first, leftmost, column
      @current_column = @columns.next
      
      # draw red outline/stroke around the columns that have content
      TTV::Prawn::Util.stroke_rect(@pdf, @current_column)
      
    end
    context "with a simple enclosing rectangle" do
      setup do
        # length is 400 pts, width is 200 pts
        top = 500; left = 50; bottom = 100; right = 250
        @enclosing_column_rect = AbstractBallot::Rect.new(top, left, bottom, right)
        # draw red outline/stroke to enclosing column
        TTV::Prawn::Util.stroke_rect(@pdf, @enclosing_column_rect)

        
        @question = create_question("Dog Racing", @district, @election, "This proposed law would ")
        @question_flow = DefaultBallot::FlowItem::Question.new(@pdf, @question, @scanner)
      end # end setup
      
      should "create a question flow" do
        assert @question
        assert @question_flow.instance_of?(DefaultBallot::FlowItem::Question)
      end

      should "draw on question" do
        @question_flow.draw(@ballot_config, @enclosing_column_rect)
        @pdf.render_file("#{Rails.root}/tmp/question_flow_form_simple.pdf")
      end
      
    end # end context

    
  end # end context
end
