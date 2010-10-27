require 'test_helper'
require 'ballots/default/contest_flow'

class ContestFlowFormTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Contest" do
    setup do
      # create a ballot config without a pdf form
      # create_ballot_config(false)
      
      # create a ballot config for pdf form
      create_ballot_config(true)
      
      # create a flow rect/frame to enclose all the columns
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
        
      # draw aqua outline/stroke around the flow rectangle
      TTV::Prawn::Util.stroke_rect(@pdf, flow_rect, "#ffffff")
        
      # create 3 columns of equal width within the frame
      @columns = TTV::Ballot::Columns.new(3, flow_rect)
        
      # get the first, leftmost, column
      @current_column = @columns.next
        
      # draw red outline/stroke around the columns that have content
      TTV::Prawn::Util.stroke_rect(@pdf, @current_column)
    end
    context "that overflows" do
      setup do
        # create 5 contests 
        @flow_items = []
        %w{  Contest1 Contest2 Contest3 Contest4 Contest5 }.each do |name|
          contest = create_contest(name, VotingMethod::WINNER_TAKE_ALL, @district, @election )
          @flow_items <<       @contest_flow = DefaultBallot::FlowItem::Contest.new(@pdf, contest, @scanner)      
        end

      end
      
      should "draw in two columns" do
        
        @flow_items.each do |contest_flow|
          
          fits = contest_flow.fits(@ballot_config, @current_column)
          @current_column = @columns.next unless fits

          contest_flow.draw(@ballot_config, @current_column)
        end
        
        #reader = TTV::Prawn::Reader.new(@pdf)
        
        # make sure we've bumped up the current column 
        assert_not_equal @columns.first, @current_column

        # make sure the object store annotation ref has the same set
        # of references as the page annotation ref!!
        #assert_equal @pdf.annotations_in_object_store, @pdf.annotations

        @pdf.render_file("#{Rails.root}/tmp/contest_flow_form2.pdf")

      end
    end
    
  end
end
