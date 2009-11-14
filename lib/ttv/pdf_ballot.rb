
require '../../test/test_helper'

require 'prawn'
require 'prawn/format'

class PDFBallotTest < ActiveSupport::TestCase
  def test_GenerateBallot
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

    class FlowItem

      def initialize(item)
        @item = item
      end

      def fits(config, rect)
        # clever way to see if we fit, avoiding code duplication for measure vs. draw
        # Algorithm: draw the item. If it overflows flow rectangle, it does not fit.
        r = rect.clone;
        config.pdf.transaction do
          draw_into(config, r)
          config.pdf.rollback
        end
        r.height > 0
      end

      def draw_into(config, rect)
        top = rect.top
        config.pdf.font("Helvetica", :size => 10, :style => :italic)
        config.pdf.bounding_box([rect.left + 2, rect.top], :width => rect.width - 2 ) do
          config.pdf.move_down 3
          config.pdf.text "FlowItem.draw_into"
          rect.top -= config.pdf.bounds.height
        end
        config.pdf.stroke_line [rect.left, rect.top], [rect.right, rect.top]
        config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
      end

      class Header < FlowItem
        def draw_into(config, rect)
          top = rect.top
          config.pdf.font("Helvetica", :size => 10, :style => :bold )
          config.pdf.bounding_box([rect.left + 2, rect.top], :width => rect.width - 2) do
            config.pdf.move_down 3
            config.pdf.text @item, :leading => 1
            rect.top -= config.pdf.bounds.height 
          end
          config.pdf.line_width 0.5
          config.pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
          config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
        end
      end

      class Question < FlowItem
        def draw_into(config, rect)
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
          config.pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
          config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
        end
      end

      class Contest < FlowItem
        def draw_into(config, rect)
          top = rect.top
          config.pdf.bounding_box([rect.left+2, rect.top], :width => rect.width - 2) do
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
          config.pdf.line_width 0.5
          config.pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
          config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
        end
      end

    end

    class BallotConfig
      attr_accessor :pdf, :page_size, :left_margin, :right_margin, :top_margin, :bottom_margin, :columns
      def initialize()
        @page_size = "LETTER"
        @left_margin = @right_margin = 18
        @top_margin = @bottom_margin = 30
        @pleaseVoteHeight = 30
        @padding = 8
        @columns = 3
        Rails.logger.info("My ancestors are #{self.ancestors}")
        @file_root = "#{RAILS_ROOT}/ballots/#{}/ballot_config.rb"
      end

      def setup(pdf, election, precinct)
        @pdf = pdf
        @election = election
        @precinct = precinct
        # FIXME - uncomment when 
        #        pdf.font_families.update({
        #           "Helvetica" => { :normal => "/Library/Fonts/Arial Unicode.ttf",
        #                            :bold => "/Library/Fonts/Arial Bold.ttf" },
        #          "Courier" => { :normal => "/Library/Fonts/Courier New.ttf" }}
        #          )
      end

      def load_text(filename)
        
      end
      
      def load_image(filename)
        
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
          stroke_bounds
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
            @pdf.text @election.display_name, :align => :center
            @pdf.text @precinct.display_name, :align => :center
            @pdf.move_down(@padding / 3)
            flow_rect.top -= @pdf.bounds.height  
          end
        end
        @pdf.stroke_color "000000"
        @pdf.stroke_line [flow_rect.left, flow_rect.top], [flow_rect.right, flow_rect.top]
      end

      def render_column_instructions(flow_rect, page)
        return if page != 1
        @pdf.bounding_box [flow_rect.left + @padding, flow_rect.top], 
                          :width => flow_rect.width - @padding * 2 do
            @pdf.text
        end
        flow_rect.top = flow_rect.bottom
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

      def render_page(pagenum)
        @pdf.start_new_page
        flow_rect = Rect.create_bound_box(@pdf.bounds)
        @c.render_frame(flow_rect)
        @c.render_header(flow_rect)
        column_rects = []
        column_width = flow_rect.width / ( @c.columns * 1.0)
        @c.columns.times do |x|
          column_rects.push Rect.create_wh(flow_rect.top, flow_rect.left + column_width *x,
          column_width, flow_rect.height)
        end
        0.upto(@c.columns-1) do |x|
          [column_rects[x].right, column_rects[x].bottom] 
        end
        col = 0
        # try to fill up all the columns with items
        while @flow_items.size > 0
          if @flow_items.first.fits(@c, column_rects[col])
            @flow_items.shift.draw_into(@c, column_rects[col])
          else
            if column_rects[col].top == flow_rect.top # if column is full height
              @pdf.stroke_color "FF0000"
              @flow_items.first.draw_into(self, column_rects[col])
            end
            col += 1
            break if col == @c.columns
          end
        end
        @c.page_complete(pagenum, @flow_items.size > 0)
      end
    end

    def self.getBallotConfig(style)
      style ||= "default"
      return BallotConfig.new() if style == "default"
      
      name = "#{RAILS_ROOT}/ballots/#{style}/ballot_config.rb"
      if File.exists? name
        begin
          load name
          c = TTV::PDFBallot.const_get(style.camelize).const_get("BallotConfig")
          c.new
        rescue
          raise "File #{name} has not defined TTV::PDFBallot::#{style.camelize}::BallotConfig "
        end
      else
        raise "Illegal ballot style: file #{name} does not exist."
      end
    end

    def self.create(election, precinct, style='default')
      renderer = Renderer.new(election, precinct, getBallotConfig('aiga'))
      renderer.render
      renderer.to_s
    end
  end
end

