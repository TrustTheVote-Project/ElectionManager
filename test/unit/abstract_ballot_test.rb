require 'test_helper'
require 'ballots/default/ballot_config.rb'

class AbstractBallotTest < ActiveSupport::TestCase
  
  SIDE_MARGIN =  18
  TOP_BOTTOM_MARGIN = 30

  context "AbstractBallot::" do
    
    setup do
      meta_data = { :Creator => "TrustTheVote", :Title => "Abstract Ballot Test" }
      @pdf = create_pdf("Abstract Ballot Test",
                                 :page_layout => :portrait,
                                 # LETTER
                                 # width =  612.00 points
                                 # length = 792.00  points
                                 :page_size => "LETTER",
                                 :left_margin => SIDE_MARGIN,
                                 :right_margin => SIDE_MARGIN,
                                 :top_margin => TOP_BOTTOM_MARGIN,
                                 :bottom_margin => TOP_BOTTOM_MARGIN,
                                 :skip_page_creation => false,
                                 :info => meta_data
                                 )

      # puts "bottom_left = #{@pdf.bounds.bottom_left.inspect}"
      # puts "bottom_right = #{@pdf.bounds.bottom_right.inspect}"
      # puts "top_left = #{@pdf.bounds.top_left.inspect}"
      # puts "top_right = #{@pdf.bounds.top_right.inspect}"

    end # end setup
    context "Rect" do
      should "create a bounding box" do

        rect_for_page = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
        # puts "rect_for_page  = #{rect_for_page.inspect}"
        
        assert_equal rect_for_page.left, @pdf.bounds.bottom_left.first
        assert_equal rect_for_page.bottom, @pdf.bounds.bottom_left.last
        assert_equal rect_for_page.right, @pdf.bounds.bottom_right.first
        assert_equal rect_for_page.top, @pdf.bounds.top_right.last
        
        #        assert_equal rect_for_page.width, 576.0
        assert_equal rect_for_page.width, 612.0 - (SIDE_MARGIN * 2 )
        assert_equal rect_for_page.height, 792.0  - (TOP_BOTTOM_MARGIN * 2 )
        assert rect_for_page.full_height?
      end
    end
    

    context "Columns" do
      setup do
        @num_columns = 5
        
        page_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
        
        # break up the page into 5 columns
        @columns = AbstractBallot::Columns.new(@num_columns, page_rect)
      end
      
      should "create some columns" do
        # puts "Columns = #{@columns.to_s}"
        width = (612.0 - (SIDE_MARGIN * 2 ))/@num_columns
        @num_columns.times do
          c = @columns.next
          assert_in_delta c.width, width, 0.1
        end
      end
    end
    
    context "WideColumn" do
      # TODO: Fix this, it's soo wrong!!! Not sure how this WideColumn
      # is supposed to work??
      # FIXME:
      setup do
        @rects = []
        num_rects = 4
        # top, left, bottom, right
        [
         [50, 0, 0, 50], [100,0, 50, 50], # column 1
         [50, 60, 0, 110], [100,60, 50, 110] # column 2
        ].each do |box|
          rect = TTV::Ballot::Rect.create(box[0],box[1],box[2],box[3])
#          puts "rect = #{rect.inspect}"
          @rects << rect
        end
        @wide_column = TTV::Ballot::WideColumn.new(@rects)
      end # end setup
      
      should "be true " do
        assert @wide_column
#         puts "@wide_column.width = #{@wide_column.width.inspect}"
#         puts "@wide_column.height = #{@wide_column.height.inspect}"
        
#         puts "@wide_column.top = #{@wide_column.top.inspect}"
#         puts "@wide_column.left = #{@wide_column.left.inspect}"
#         puts "@wide_column.bottom = #{@wide_column.bottom.inspect}"
#         puts "@wide_column.right = #{@wide_column.right.inspect}"
      end
    end # end WideColumns context

  end # end AbstractBallot:: Context
end
