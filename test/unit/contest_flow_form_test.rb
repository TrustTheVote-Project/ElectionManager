require 'test_helper'
require 'ballots/default/contest_flow'

class ContestFlowTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Contest" do
    setup do
      # create a ballot config without a pdf form
      # create_ballot_config(false)
      
      # create a ballot config for pdf form
      create_ballot_config(true)
      
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
              
        @contest = create_contest("US Senate", VotingMethod::WINNER_TAKE_ALL, @district, @election )
        @contest_flow = DefaultBallot::FlowItem::Contest.new(@pdf, @contest, @scanner)      
      end
      
      should "create a contest flow" do
        assert @contest
        assert @contest.instance_of?(Contest)
      end
      
      should "draw one contest" do
        @contest_flow.draw(@ballot_config, @enclosing_column_rect)
        @pdf.render_file("#{Rails.root}/tmp/contest_flow_form_simple.pdf")
      end

      # Somehow, the pdf output is different after transaction and rollback??
      # should "render the same file contents after a rollback" do
      #   @contest_flow.draw(@ballot_config, @enclosing_column_rect)
      #   @pdf.render_file("#{Rails.root}/tmp/contest_flow_without_fits.pdf")
      #   @contest_flow.fits(@ballot_config, @enclosing_column_rect)
      #   @pdf.render_file("#{Rails.root}/tmp/contest_flow_with_fits.pdf")
      # end
    end
    
    context "that does not overflow" do
      setup do
        # create 2 contests 
        @flow_items = []
        %w{  Contest1 Contest2 }.each do |name|
          contest = create_contest(name, VotingMethod::WINNER_TAKE_ALL, @district, @election )
          @flow_items <<  @contest_flow = DefaultBallot::FlowItem::Contest.new(@pdf, contest, @scanner)      
        end
      end

      # TODO: complete this test.
      should "have valid annotation metadata" do
        # check that the generate pdf had correct identifiers for each
        # annotation, (textfield, checkbox, etc.)
        # See PT story 4136021
        # Ex: /T (ident-US_Senate+US_Senate_dem+US_Senate)
      end
      
      should "should fit all contests" do
        @flow_items.each do |contest_flow|
          assert contest_flow.fits(@ballot_config, @current_column)
        end
      end
      
      should "draw in one column" do
        @flow_items.each do |contest_flow|
          contest_flow.draw(@ballot_config, @current_column)
          end
        @pdf.render_file("#{Rails.root}/tmp/contests_flow_form_one_column.pdf")
      end
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
        
        # make sure we've bumped up the current column 
        #assert_not_equal @columns.first, @current_column

        #puts "TGD: final annotation in store #{@pdf.annotations_in_object_store}"
        #puts "TGD: final annotations are #{@pdf.annotations}"
        
        # make sure the object store annotation ref has the same set
        # of references as the page annotation ref!!
        #assert_equal @pdf.annotations_in_object_store, @pdf.annotations
        
        @pdf.render_file("#{Rails.root}/tmp/contests_flow_form_into_two_columns.pdf")

      end
    end
    
  end
end
