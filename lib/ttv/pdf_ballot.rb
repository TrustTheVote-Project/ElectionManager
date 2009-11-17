
require '../../test/test_helper'

require 'prawn'
require 'prawn/format'
class PDFBallotTest < ActiveSupport::TestCase
  def test_GenerateBallot
    Rails.logger.level = 3
    election = Election.find(:first)
    precinct = election.district_set.precincts[12]
    pdf = TTV::PDFBallot.create(election, precinct)
    f = File.new("#{RAILS_ROOT}/test/PDFBallot.pdf", 'w')
    f.write(pdf)
    f.close
    `open /Applications/Preview.app #{f.path}`
    assert_not_nil(election)
    assert_not_nil(precinct)
  end
end

module TTV
  module PDFBallot
    class Rect
      attr_accessor :top, :left, :bottom, :right

      def initialize(top, left, bottom, right)
        @top, @left, @bottom , @right = top, left, bottom, right
      end

      def width
        right - left
      end

      def height
        top - bottom
      end

      def to_s
        "T:#{@top} L:#{@left} B:#{@bottom} R:#{@right} W:#{self.width} H:#{self.height}"
      end

      def inset(horiz, vertical)
        @top -= vertical
        @bottom += vertical
        @left += horiz
        @right -= horiz
      end

      def self.create(top, left, bottom, right)
        return new(top, left, bottom, right)
      end

      def self.create_wh(top, left, width, height)
        return new(top, left, top - height, left + width)
      end

      def self.create_bound_box(bb)
        return self.create(bb.top, bb.left, bb.bottom, bb.right)
      end
    end

    # WideColumn is used in layout to group columns together
    # its boundaries are leftmost/rightmost/lowest top/highest bottom
    class WideColumn
       def initialize (rects)
         @rects = rects
       end

       def initialize_copy(old)
         @rects =  @rects.map { |r| r.clone }
       end
       
       def top
         @rects.map { |r| r.top}.min
       end
       def top=(x)
         @rects.each { |r| r.top = x }
       end        
       def bottom
         @rects.map { |r| r.bottom}.max
       end
       def bottom=(x)
         @rects.each { |r| r.bottom = x} 
       end
       def left
         @rects.map { |r| r.left}.min
       end
       def right
         @rects.map { |r| r.right}.max
       end
       
       def width
         right - left
       end

       def height
         top - bottom
       end
       
       def index(r)
         @rects.index(r)
       end
       
       def first
         @rects.first
       end
       
       def to_s
          s = "T:#{top} L:#{left} B:#{bottom} R:#{right} W:#{width} H#{height}\n\n"
          @rects.each do |r| 
            s += "Combo: #{r.to_s}\n" 
          end
          s
       end        
     end

    class FlowItem

      def initialize(item)
        @item = item
      end

      def fits(config, rect)
        # clever way to see if we fit, avoiding code duplication for measure vs. draw
        # Algorithm: draw the item. If it overflows flow rectangle, it does not fit.
        r = rect.clone;
        config.pdf.transaction do
          draw(config, r)
          config.pdf.rollback
        end
        r.height > 0
      end

      def draw(config, rect)
        # debug only code
        top = rect.top
        config.pdf.font("Helvetica", :size => 10, :style => :italic)
        config.pdf.bounding_box([rect.left + 2, rect.top], :width => rect.width - 2 ) do
          config.pdf.move_down 3
          config.pdf.text "FlowItem.draw"
          rect.top -= config.pdf.bounds.height
        end
        config.pdf.stroke_line [rect.left, rect.top], [rect.right, rect.top]
        config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
      end

      def min_width
        0
      end

      class Header < FlowItem
        def min_width
          1
        end
        
        def draw(config, rect)
          top = rect.top
          config.pdf.font("Helvetica", :size => 10, :style => :bold )
          config.pdf.bounding_box([rect.left + 2, rect.top], :width => rect.width - 2) do
            config.pdf.move_down 3
            config.pdf.text @item, :leading => 1
            rect.top -= config.pdf.bounds.height 
          end
          config.frame_item rect, top
        end
      end

      class Question < FlowItem

        def min_width
          return 300 if @item.question.length > 100
          0
        end

        def draw(config, rect)
          top = rect.top
          config.pdf.bounding_box([rect.left+2, rect.top], :width => rect.width - 2) do
            config.pdf.font "Helvetica", :size => 10, :style => :bold
            config.pdf.move_down 3
            config.pdf.text @item.display_name, :leading => 1 #header
            config.pdf.move_down 6
            config.pdf.font "Helvetica", :size => 10
            config.pdf.text @item.question, :leading => 1 # question
            rect.top -= config.pdf.bounds.height
          end
          rect.top -= 3
          config.draw_checkbox rect, "Yes"
          rect.top -= 3
          config.draw_checkbox  rect, "No"
          config.pdf.line_width 0.5
          rect.top -= 3
          config.frame_item rect, top
        end
      end

      class Contest < FlowItem
        def draw(config, rect)
          top = rect.top
          config.pdf.bounding_box [rect.left+2, rect.top], :width => rect.width - 2 do
            config.pdf.font "Helvetica", :size => 10, :style => :bold
            config.pdf.move_down 3
            config.pdf.text @item.display_name, :leading => 1 #header
            rect.top -= config.pdf.bounds.height
          end
          @item.candidates.each do |candidate|
            rect.top -= 6
            config.draw_checkbox rect, candidate.display_name + "\n" + candidate.party.display_name
          end
          @item.open_seat_count.times do
            rect.top -= 6
            left = config.draw_checkbox rect, "or write in"
            config.pdf.dash 1
            v = 16
            config.pdf.stroke_line [rect.left + left, rect.top - v], 
            [rect.right - 6, rect.top - v]
            rect.top -= v
            config.pdf.undash
          end
          rect.top -= 6 if @item.open_seat_count != 0
          config.frame_item rect, top
        end
      end

    end

    class ContinuationBox
      def initialize(pdf)
        @pdf = pdf
      end

      def height(rect, continue = false)
        r = rect.clone;
        @pdf.transaction do
          draw(r, continue)
          @pdf.rollback
        end
        rect.top - r.top
      end

      def draw(rect, continue)
        top = rect.top
        @pdf.font "Helvetica", :size => 10, :style => :bold
        if continue
          circle_width = 20
          text_height = 0
          text_width = rect.width - circle_width - 8
          @pdf.bounding_box [rect.left+2, rect.top], :width => text_width do
            @pdf.move_down 6
            @pdf.text "Continue voting\nnext side", :align => :center
            @pdf.move_down 2
            text_height = @pdf.bounds.height
          end
          circle_top = rect.top - 6
          @pdf.bounding_box [rect.left + text_width, circle_top ], :width => rect.width - text_width - 8 , :height => circle_width do
            @pdf.circle_at [circle_width / 2, circle_width / 2], :radius => circle_width / 2
            @pdf.fill_color "000000"
            @pdf.fill_and_stroke
            @pdf.stroke_color "FFFFFF"
            @pdf.cap_style :round
            @pdf.line_width 2
            inset = 4
            @pdf.stroke_line [inset, circle_width / 2], [ circle_width - inset, circle_width / 2]
            @pdf.move_to [circle_width / 2, circle_width - inset]
            @pdf.line_to [circle_width - inset, circle_width / 2]
            @pdf.line_to [circle_width / 2, inset]
            @pdf.stroke
          end
          rect.top -= text_height
        else
          @pdf.bounding_box [rect.left + 2, rect.top], :width => (rect.width - 4) do
            @pdf.move_down 6
            @pdf.text "Thank you for voting!\nPlease turn in your finished ballot", :align => :center
            @pdf.move_down 2
            rect.top -= @pdf.bounds.height
          end
        end
        @pdf.line_width 0.75
        @pdf.stroke_color "000000"
        @pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
        @pdf.stroke_line [rect.right, rect.top], [rect.right, top]
        @pdf.stroke_line [rect.left, rect.top], [rect.left, top]
      end
    end

    class BallotConfig

      attr_accessor :pdf, :page_size, :left_margin, :right_margin, :top_margin, :bottom_margin, :columns

      def initialize(style)
        @page_size = "LETTER"
        @left_margin = @right_margin = 18
        @top_margin = @bottom_margin = 30
        @pleaseVoteHeight = 30
        @padding = 8
        @columns = 3
        @file_root = "#{RAILS_ROOT}/ballots/#{style}/"
      end

      def setup(pdf, election, precinct)
        @pdf = pdf
        @election = election
        @precinct = precinct
        pdf.font_families.update({
                  "Helvetica" => { :normal => "/Library/Fonts/Arial Unicode.ttf",
                                    :bold => "/Library/Fonts/Arial Bold.ttf" },
                  "Courier" => { :normal => "/Library/Fonts/Courier New.ttf" }}
                  ) if false 
      end

      def load_text(filename)
        IO.read("#{@file_root}#{filename}")
      end

      def image_path(filename)
        full_path = "#{@file_root}#{filename}"
      end

      def load_image(filename)
        return Prawn::Images::PNG.new(IO.read(image_path(filename))) if filename =~ /png$/
        return Prawn::Images::JPG.new(IO.read(image_path(filename)))
      end

      def create_continuation_box
        ContinuationBox.new(@pdf)
      end

      def create_columns(flow_rect)
        Columns.new(@columns, flow_rect)
      end

      def wide_style
        # do narrow flow items continue flowing after wide ones?
        return :continue
      end
      
      def debug_stroke_bounds #debug version, rainbow of colors
        @stroke_colors = ["FF0000", "00FF00", "0000FF", "FFFF00", "FF00FF", "00FFFF"] unless @stroke_colors
        old = @pdf.stroke_color
        @pdf.stroke_color = @stroke_colors.shift
        @pdf.dash(1)  if @pdf.bounds.height == 0
        @pdf.stroke_rectangle @pdf.bounds.top_left, @pdf.bounds.width, [@pdf.bounds.height, 30].max
        @pdf.undash
        Rails.logger.info("bounds.height: #{@pdf.bounds.to_s}")
        @stroke_colors.push @pdf.stroke_color
        @pdf.stroke_color = old
      end

      def debug_rect(r)
        @pdf.bounding_box([r.left, r.top], :width => r.width, :height => r.height) do 
          debug_stroke_bounds
        end
      end

      def draw_checkbox(rect, text)
        bbwidth, bbheight = 22, 10
        @pdf.bounding_box [rect.left+6, rect.top], :width => rect.width - 2 do
          @pdf.line_width 1.5
          @pdf.stroke_rectangle [0,0], bbwidth, bbheight
          @pdf.line_width 1
        end
        spacer = 6 + bbwidth + 6
        @pdf.bounding_box [rect.left + spacer, rect.top], :width => rect.width - spacer do
          @pdf.font "Helvetica", :size => 10
          @pdf.text text
          rect.top -= [@pdf.bounds.height, bbheight].max
        end
        spacer  # returns left-hand side of text position
      end

      def frame_item(rect, top)
        @pdf.line_width 0.5
        @pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
        @pdf.stroke_line [rect.right, rect.top], [rect.right, top]
        @pdf.stroke_line [rect.left, rect.top], [rect.left, top]
      end

      def render_frame(flow_rect)
        barWidth = 18
        barHeight = 140

        @pdf.bounding_box [0, @pdf.bounds.height - @pleaseVoteHeight], :width => @pdf.bounds.width, :height => @pdf.bounds.height - @pleaseVoteHeight * 2 do
          @pdf.fill_color = "#000000"
          @pdf.rectangle [0,barHeight], barWidth, barHeight
          @pdf.rectangle @pdf.bounds.top_left, barWidth, barHeight
          @pdf.rectangle [@pdf.bounds.right - barWidth, barHeight], barWidth, barHeight
          @pdf.fill_and_stroke
          @pdf.stroke_rectangle [barWidth + @padding,@pdf.bounds.height], 
          @pdf.bounds.width - (barWidth + @padding)* 2, @pdf.bounds.height
          @pdf.font("Courier", :size => 14)
          @pdf.text "Sample Ballot", :at => [16, 275], :rotate => 90
          @pdf.text "Sample Ballot", :at => [@pdf.bounds.right - 2 , 275], :rotate => 90
          @pdf.text "12001040100040", :at => [16, 410], :rotate => 90
          @pdf.text "132301113", :at => [@pdf.bounds.right - 2, 146], :rotate => 90
          flow_rect.inset barWidth + @padding, @pleaseVoteHeight
        end
      end

      def render_header(flow_rect)
        @pdf.font "Helvetica", :size => 13,  :style => :bold
        @pdf.bounding_box [flow_rect.left + @padding, flow_rect.top], 
        :width => flow_rect.width - @padding do
          @pdf.move_down 3
          @pdf.text "OFFICIAL BALLOT"
          @pdf.text @election.start_date.strftime("%B %d, %Y")
          @pdf.bounding_box [@pdf.bounds.width / 3,  @pdf.bounds.height], 
          :width => @pdf.bounds.width * 2 / 3 do
            @pdf.move_down 3
            @pdf.text @election.display_name, :align => :center
            @pdf.text @precinct.display_name, :align => :center
            @pdf.move_down(@padding / 3)
            flow_rect.top -= @pdf.bounds.height  
          end
        end
        @pdf.stroke_color "000000"
        @pdf.stroke_line [flow_rect.left, flow_rect.top], [flow_rect.right, flow_rect.top]
      end

      def render_column_instructions(rect, page)
        return if page != 1
        top = rect.top
        @pdf.font "Helvetica", :size => 9, :style => :bold
        @pdf.bounding_box [rect.left + @padding, rect.top], 
        :width => rect.width - @padding * 2 do
          @pdf.move_down 3
          @pdf.text load_text("instructions1.txt")
          img = load_image "instructions2.png"
          @pdf.image image_path("instructions2.png"), 
          :width => [img.width * 72 / 96, @pdf.bounds.width].min
          @pdf.move_down 3
          @pdf.text load_text("instructions3.txt")
        end
        rect.top = rect.bottom
        @pdf.line_width 0.5
        @pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
        @pdf.stroke_line [rect.right, rect.top], [rect.right, top]
      end

      def page_complete(pagenum, last_page)
        if last_page
          @pdf.font "Helvetica", :size => 14, :style => :bold
          @pdf.bounding_box [ 0 , @pdf.bounds.height ], :width => @pdf.bounds.width do
            @pdf.text "Vote Both Sides", :align => :center
          end
          @pdf.bounding_box [ 0 , @pleaseVoteHeight ], :width => @pdf.bounds.width do
            @pdf.move_down 10
            @pdf.text "Vote Both Sides", :align => :center
          end
        end
      end

      def create_flow_item(item)
        case
        when item.is_a?(Contest) then FlowItem::Contest.new(item)
        when item.is_a?(Question) then FlowItem::Question.new(item)
        when item.is_a?(String) then FlowItem::Header.new(item)
        end
      end
      
    end
    
    # encapsulates columns for rendering
    class Columns
      def initialize(col_count, flow_rect)
        @column_rects = []
        column_width = flow_rect.width / ( col_count * 1.0)
        col_count.times do |x|
          @column_rects.push Rect.create_wh(flow_rect.top, flow_rect.left + column_width *x,
          column_width, flow_rect.height)
        end
        @next = @column_rects.first
      end

      def to_s
        s = ""
        @column_rects.each do |c|
          s += "#{c}\n"
        end
        s
      end
      
      def next
        retval = @next
        Rails.logger.error "r is #{retval}"
        @next = @column_rects[@column_rects.index(@next) + 1] if @next
        retval
      end

      def first
        @column_rects.first
      end
      
      def last
        @column_rects.last
      end

      def current=(r)
        @next = @column_rects[@column_rects.index(r) + 1]
      end
      
      def make_wide(column, width)
        cols = [column]
        i = @column_rects.index(column) + 1
        total = column.width
        while (total < width && i < @column_rects.size)
          newCol = @column_rects[i]
          @next = @column_rects[i+1]
          total += newCol.width
          cols.push newCol
        end
        return WideColumn.new(cols) if total >= width
        nil
      end      
    end

    class Renderer

      def initialize(election, precinct, config)
        @election = election
        @precinct = precinct
        @c = config
      end

      def to_s
        @pdf.render
      end

      def render
        @pdf = Prawn::Document.new(
        :page_size => @c.page_size, 
        :left_margin => @c.left_margin,
        :right_margin => @c.right_margin,
        :top_margin => @c.top_margin,
        :bottom_margin => @c.bottom_margin,
        :skip_page_creation => true,
        :info => { :Creator => "TrustTheVote",
          :Title => "#{@election.display_name} #{@precinct.display_name} ballot"
        }
        )
        @c.setup(@pdf, @election, @precinct)

        # initialize flow items
        @flow_items = []
        @precinct.districts(@election.district_set).each do |district|
          @flow_items.push(@c.create_flow_item(district.display_name))
          district.contestsForElection(@election).each do |contest|
            @flow_items.push(@c.create_flow_item(contest))
          end
          district.questionsForElection(@election).each do |question|
            @flow_items.push(@c.create_flow_item(question))
          end
        end       

        # render all pages
        page = 0
        while @flow_items.size > 0
          page += 1
          render_page page
        end
      end

      def render_flow_rect(flow_rect, pagenum)
        columns = @c.create_columns(flow_rect)

        # make space for continuation box
        continuation_box = @c.create_continuation_box
        columns.last.bottom += continuation_box.height(columns.last, true)

        @c.render_column_instructions(columns.first, pagenum)

        curr_column = columns.next
        last_column = curr_column
        while @flow_items.size > 0
          item = @flow_items.first

          if item.min_width != 0 # fit the wide items in narrow column
            if item.min_width > curr_column.width
              if curr_column.top == flow_rect.top
                curr_column = columns.make_wide curr_column, item.min_width
              else
                curr_column = columns.make_wide columns.next, item.min_width
              end
            end
          elsif curr_column.class == WideColumn # fit narrow items in wide column
            if @c.wide_style == :continue
              curr_column = curr_column.first
              columns.current = curr_column
            else
              curr_column = columns.next
            end
          end
          break if curr_column == nil

          if item.fits @c, curr_column
            last_column = curr_column
            @flow_items.shift.draw @c, curr_column
          else
            if curr_column.top == flow_rect.top # if column is full height, can't break up items yet
              @pdf.stroke_color "FF0000"  # draw an error column in red
              item.draw @c, curr_column
            end
            curr_column = columns.next
            break if curr_column == nil
          end
        end

        # draw continuation text in last used column, or last column if no space
        continuation_col = last_column
        if (continuation_col.height < 
          continuation_box.height(continuation_col, @flow_items.size != 0) )
          if ! (continuation_col.class == WideColumn && continuation_col.index(columns.last))
              continuation_col = columns.last
          end
        end
        continuation_box.draw(continuation_col, @flow_items.size != 0)
      end

      def render_page(pagenum)
        @pdf.start_new_page

        flow_rect = Rect.create_bound_box(@pdf.bounds)
        @c.render_frame flow_rect
        @c.render_header flow_rect
        render_flow_rect flow_rect, pagenum

        @c.page_complete(pagenum, @flow_items.size > 0)
      end
    end

    def self.get_ballot_config(style)
      style ||= "default"
      return BallotConfig.new(style) if style == "default"

      name = "#{RAILS_ROOT}/ballots/#{style}/ballot_config.rb"
      if File.exists? name
        begin
          load name
          c = TTV::PDFBallot.const_get(style.camelize).const_get("BallotConfig")
          c.new(style)
        rescue
          raise "File #{name} has not defined TTV::PDFBallot::#{style.camelize}::BallotConfig "
        end
      else
        raise "Illegal ballot style: file #{name} does not exist."
      end
    end

    def self.create(election, precinct, style='default')
      renderer = Renderer.new(election, precinct, get_ballot_config(style))
      renderer.render
      renderer.to_s
    end
  end
end

