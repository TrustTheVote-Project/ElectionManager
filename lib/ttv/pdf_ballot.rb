
#require '../../test/test_helper'

require 'prawn'

if false
class PDFBallotTest < ActiveSupport::TestCase
 
  def test_generate_ballot
    file = File.new( RAILS_ROOT + "/test/elections/candidates_100.xml")
#    file = File.new( RAILS_ROOT + "/test/elections/candidates_100_ranked.xml")
    election_to_ballot(file) 
  end
  
  def election_to_ballot(file)
    ActiveRecord::Base.transaction do
      election = TTV::ImportExport.import(file)
      precinct = election.district_set.precincts.first
      lang = 'zh'
      pdf = TTV::PDFBallot.create(election, precinct, 'default', lang)
      f = File.new("#{RAILS_ROOT}/test/tmp/#{File.basename(file.path, '.xml')}.#{lang}.pdf", 'w')
      f.write(pdf)
      f.close
      `open  #{f.path}`
    end
  end
end
end

module TTV
  module PDFBallot
    class Rect
      attr_accessor :top, :left, :bottom, :right

      def initialize(top, left, bottom, right)
        @top, @left, @bottom , @right = top, left, bottom, right
        @original_top = @top
      end

      def width
        right - left
      end

      def height
        top - bottom
      end

      def to_s
        "#{full_height? ? 'empty' : ''  }T:#{@top} L:#{@left} B:#{@bottom} R:#{@right} W:#{self.width} H:#{self.height}"
      end

      def inset(horiz, vertical)
        @top -= vertical
        @bottom += vertical
        @left += horiz
        @right -= horiz
      end

      def first
        self
      end

      def full_height?
        @original_top == @top
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
        @original_top = top
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

      def full_height?
        @original_top == top
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

      ANY_WIDTH = 1
      HPAD = 3
      HPAD2 = 6
      VPAD = 3

      def initialize(item)
        @item = item
      end

      def fits(config, rect)
        # clever way to see if we fit, avoiding code duplication for measure vs. draw
        # Algorithm: draw the item. If it overflows flow rectangle, it does not fit.
        r = rect.clone
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
        config.pdf.bounding_box([rect.left + HPAD, rect.top], :width => rect.width - HPAD ) do
          config.pdf.move_down VPAD
          config.pdf.text "FlowItem.draw"
          rect.top -= config.pdf.bounds.height
        end
        config.pdf.stroke_line [rect.left, rect.top], [rect.right, rect.top]
        config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
      end

      def min_width
        0
      end
      
      def to_s
        @item.to_s
      end

      class Combo
        def initialize(flow_items)
          @flow_items = flow_items
        end

        def fits(config, rect)
          r = rect.clone
          config.pdf.transaction do
            @flow_items.each { |f|  f.draw config, r if r.height > 0 }
            config.pdf.rollback
          end
          r.height > 0
        end

        def min_width
          @flow_items.map { |r| r.min_width }.max
        end

        def draw(config, rect, &bloc)
          @flow_items.each { |f| f.draw config, rect, &bloc }
        end
        
        def to_s
          s = "Combo\n"
          @flow_items.each { |f| s += f.to_s + "\n" }
          s
        end
      end

      class Header < FlowItem
        def min_width
          ANY_WIDTH
        end

        def draw(config, rect)
          top = rect.top
          config.pdf.font("Helvetica", :size => 10, :style => :bold )
          config.pdf.bounding_box([rect.left + HPAD, rect.top], :width => rect.width - HPAD * 2) do
            config.pdf.move_down VPAD
            config.pdf.text @item, :leading => 1
            rect.top -= config.pdf.bounds.height 
          end
          config.frame_item rect, top
        end
        
      end

      class Question < FlowItem

        def min_width
          return 300 if @item.question.length > 100
          return ANY_WIDTH
        end

        def draw(config, rect)
          top = rect.top
          config.pdf.bounding_box([rect.left+2, rect.top], :width => rect.width - 4) do
            config.pdf.font "Helvetica", :size => 10, :style => :bold
            config.pdf.move_down VPAD
            config.pdf.text @item.display_name, :leading => 1 #header
            config.pdf.move_down VPAD * 2
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

        NAME_WIDTH = 100
        MAX_RANKED = 10
        NEXT_COL_BOUNCE = 30
        
        def min_width
          if @item.voting_method_id == VotingMethod::WINNER
            super
          else
            100 + 3 * HPAD + [@item.candidates.count, MAX_RANKED].min * (HPAD + BallotConfig::CHECKBOX_WIDTH)
          end
        end

        def draw(config, rect, &bloc)
          if @item.voting_method_id == VotingMethod::WINNER
            draw_winner config, rect, &bloc
          else
            draw_ranked config, rect, &bloc
          end
        end

        def draw_winner(config, rect, &bloc)
          top = rect.top
          # HEADER
          config.pdf.bounding_box [rect.left+HPAD, rect.top], :width => rect.width - HPAD2 do
            config.pdf.font "Helvetica", :size => 10, :style => :bold
            config.pdf.move_down VPAD
            config.pdf.text @item.display_name, :leading => 1 #header
            rect.top -= config.pdf.bounds.height
          end
          # CANDIDATES
          @item.candidates.each do |candidate|
            if bloc && rect.height < NEXT_COL_BOUNCE
              config.frame_item rect, top
              rect = yield
            end
            rect.top -= VPAD * 2
            config.draw_checkbox rect, candidate.display_name + "\n" + candidate.party.display_name
          end
          @item.open_seat_count.times do
            rect.top -= VPAD * 2
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

        def draw_ranked(config, rect, &bloc)
          top = rect.top
          pdf = config.pdf
          # title
          pdf.bounding_box [rect.left+HPAD, rect.top], :width => rect.width - HPAD2 do
            pdf.font "Helvetica", :size => 10, :style => :bold
            pdf.move_down VPAD
            pdf.text @item.display_name, :leading => 1 #header
            rect.top -= pdf.bounds.height
          end

          # Ordinals: 1st 2nd...
          hpad4 = HPAD2 * 2
          rect.top -= VPAD * 2
          count = @item.candidates.count
          checkbox_count = [@item.candidates.count, MAX_RANKED].min
          height = 0
          0.upto(checkbox_count - 1) do |i|
            x = rect.left + HPAD2 + i * (BallotConfig::CHECKBOX_WIDTH + hpad4)
            y = rect.top + VPAD 
            pdf.bounding_box [x, y], :width => BallotConfig::CHECKBOX_WIDTH do
              pdf.text((i + 1).ordinalize, :align => :center)
              height = pdf.bounds.height
            end
          end
          rect.top -= height;

          # checkboxes

          0.upto(count) do |i|  # candidates
            if bloc && rect.height < NEXT_COL_BOUNCE
              config.frame_item rect, top
              rect = yield
              rect.top -= HPAD2
            end
            0.upto(checkbox_count - 1) do |j|
              x = rect.left + HPAD2 + j * (BallotConfig::CHECKBOX_WIDTH + hpad4)
              y = rect.top
              pdf.bounding_box [x, y], :width => BallotConfig::CHECKBOX_WIDTH do
                config.stroke_checkbox
                f = pdf.font "Helvetica", :size => 9
                pdf.move_down( (BallotConfig::CHECKBOX_HEIGHT - f.ascender) / 2)
                pdf.fill_color "999999"
                pdf.text j + 1, :align => :center
              end
            end
            pdf.fill_color "000000"
            spacer = HPAD2 + checkbox_count * (BallotConfig::CHECKBOX_WIDTH + hpad4)
            pdf.font "Helvetica", :size => 10
            pdf.bounding_box [rect.left + spacer, rect.top], :width => rect.width - spacer do
              if i < count
                pdf.text @item.candidates[i].display_name + "\n" + @item.candidates[i].party.display_name
              else # writein
                pdf.text config.bt[:or_write_in]
                pdf.dash 1
                pdf.move_down 16
                config.pdf.stroke_line [0, 0], [rect.width - spacer - HPAD2, 0]
                pdf.undash
                pdf.move_down VPAD
              end            
              rect.top -= [pdf.bounds.height, BallotConfig::CHECKBOX_HEIGHT].max
            end
            pdf.move_down VPAD * 2
            rect.top -= VPAD * 2
          end
          config.frame_item rect, top
        end
      end

    end

    class ContinuationBox
      def initialize(pdf)
        @pdf = pdf
      end

      def height(config, rect, last_page = false)
        r = rect.clone;
        @pdf.transaction do
          draw(config, r, last_page)
          @pdf.rollback
        end
        rect.top - r.top
      end

      def draw(config, rect, last_page)
        top = rect.top
        @pdf.font "Helvetica", :size => 10, :style => :bold
        unless last_page
          circle_width = 20
          text_height = 0
          text_width = rect.width - circle_width - 8
          @pdf.bounding_box [rect.left+FlowItem::HPAD, rect.top], :width => text_width do
            @pdf.move_down FlowItem::VPAD
            @pdf.text config.bt[:Continue_voting_next_side], :align => :center
            @pdf.move_down FlowItem::VPAD
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
          @pdf.bounding_box [rect.left + FlowItem::HPAD, rect.top], :width => (rect.width - FlowItem::HPAD2) do
            @pdf.move_down FlowItem::VPAD
            @pdf.text config.bt[:Thank_you], :align => :center
            @pdf.move_down FlowItem::VPAD
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

      CHECKBOX_WIDTH = 22
      CHECKBOX_HEIGHT = 10
      HPAD = 3
      HPAD2 = 6
      VPAD = 3

      def initialize(style, lang, translation)
        @file_root = "#{RAILS_ROOT}/ballots/#{style}"
        @ballot_translation = translation
        @lang = lang
        @page_size = "LETTER"
        @left_margin = @right_margin = 18
        @top_margin = @bottom_margin = 30
        @pleaseVoteHeight = 30
        @padding = 8
        @columns = 3
      end

      def setup(pdf, election, precinct)
        @pdf = pdf
        @election = election
        @precinct = precinct
        if @lang == "zh"  # chinese fonts, 
          pdf.font_families.update({
          "Helvetica" => { :normal => "/Library/Fonts/Arial Unicode.ttf",
                           :bold => "/Library/Fonts/Arial Unicode.ttf" },
          "Courier" => { :normal => "/Library/Fonts/Arial Unicode.ttf" }
          })
          @wrap = :character
        else
          pdf.font_families.update({
            "Helvetica" => { :normal => "/Library/Fonts/Arial Unicode.ttf",
                             :bold => "/Library/Fonts/Arial Bold.ttf" },
            "Courier" => { :normal => "/Library/Fonts/Courier New.ttf" }
              })
          @wrap = :space
        end
      end
     
      def load_text(filename)
        IO.read "#{@file_root}/lang/#{@lang}/#{filename}"
      end

      def image_path(filename)
        full_path = "#{@file_root}/lang/#{@lang}/#{filename}"
      end

      def load_image(filename)
        return Prawn::Images::PNG.new(IO.read(image_path(filename))) if filename =~ /png$/
        return Prawn::Images::JPG.new(IO.read(image_path(filename)))
      end

      def ballot_translation
        @ballot_translation
      end     
      alias bt ballot_translation
      
      def election_translation
        @election_translation
      end
      alias et election_translation
      
      def create_continuation_box
        ContinuationBox.new(@pdf)
      end

      def create_columns(flow_rect)
        Columns.new(@columns, flow_rect)
      end

      def wide_style
        # do narrow flow items continue flowing after wide ones?
        return :continue # :stop for narrow items starting new column
      end

      def debug_stroke_bounds #debug version, rainbow of colors
        @stroke_colors = ["FF0000", "00FF00", "0000FF", "FFFF00", "FF00FF", "00FFFF"] unless @stroke_colors
        old = @pdf.stroke_color
        @pdf.stroke_color = @stroke_colors.shift
        @pdf.dash(1)  if @pdf.bounds.height == 0
        @pdf.stroke_rectangle @pdf.bounds.top_left, @pdf.bounds.width, [@pdf.bounds.height, 5].max
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

      def stroke_checkbox(pt = [0,0])
        @pdf.line_width 1.5
        @pdf.fill_color "FFFFFF"
        @pdf.stroke_color "000000"
        @pdf.rectangle pt, CHECKBOX_WIDTH, CHECKBOX_HEIGHT
        @pdf.fill_and_stroke
        @pdf.fill_color "000000"
      end

      def draw_checkbox(rect, text)
        @pdf.bounding_box [rect.left + FlowItem::HPAD2, rect.top], :width => CHECKBOX_WIDTH do
          stroke_checkbox
        end
        spacer = 2 * FlowItem::HPAD2 + CHECKBOX_WIDTH
        @pdf.bounding_box [rect.left + spacer, rect.top], :width => rect.width - spacer do
          @pdf.font "Helvetica", :size => 10
          @pdf.text text
          rect.top -= [@pdf.bounds.height, CHECKBOX_HEIGHT].max
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
        bar_width = 18
        bar_height = 140

        @pdf.bounding_box [0, @pdf.bounds.height - @pleaseVoteHeight], :width => @pdf.bounds.width, :height => @pdf.bounds.height - @pleaseVoteHeight * 2 do
          @pdf.fill_color = "#000000"
          @pdf.rectangle [0,bar_height], bar_width, bar_height
          @pdf.rectangle @pdf.bounds.top_left, bar_width, bar_height
          @pdf.rectangle [@pdf.bounds.right - bar_width, bar_height], bar_width, bar_height
          @pdf.fill_and_stroke
          @pdf.stroke_rectangle [bar_width + @padding,@pdf.bounds.height], 
          @pdf.bounds.width - (bar_width + @padding)* 2, @pdf.bounds.height
          @pdf.font "Courier", :size => 14
          @pdf.text bt[:Sample_Ballot], :at => [16, 275], :rotate => 90
          @pdf.text bt[:Sample_Ballot], :at => [@pdf.bounds.right - 2 , 275], :rotate => 90
          @pdf.text "12001040100040", :at => [16, 410], :rotate => 90
          @pdf.text "132301113", :at => [@pdf.bounds.right - 2, 146], :rotate => 90
          flow_rect.inset bar_width + @padding, @pleaseVoteHeight
        end
      end

      def render_header(flow_rect)
        @pdf.font "Helvetica", :size => 13,  :style => :bold
        @pdf.bounding_box [flow_rect.left + @padding, flow_rect.top], 
        :width => flow_rect.width - @padding do
          @pdf.move_down 3
          @pdf.text bt[:OFFICIAL_BALLOT]
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

      def render_column_instructions(columns, page)
        return if page != 1
        rect = columns.next
        top = rect.top
        @pdf.font "Helvetica", :size => 9, :style => :bold
        @pdf.bounding_box [rect.left + @padding, rect.top], 
        :width => rect.width - @padding * 2 do
          @pdf.move_down 3
          @pdf.text load_text("instructions1.txt"), :wrap => @wrap 
          img = load_image "instructions2.png"
          @pdf.image image_path("instructions2.png"), 
          :width => [img.width * 72 / 96, @pdf.bounds.width].min
          @pdf.move_down 3
          @pdf.text load_text("instructions3.txt"), :wrap => @wrap
        end
        rect.top = rect.bottom
        @pdf.line_width 0.5
        @pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
        @pdf.stroke_line [rect.right, rect.top], [rect.right, top]
      end

      def page_complete(pagenum, last_page)
        unless last_page
          @pdf.font "Helvetica", :size => 14, :style => :bold
          @pdf.bounding_box [ 0 , @pdf.bounds.height ], :width => @pdf.bounds.width do
            @pdf.text bt[:Vote_Both_Sides], :align => :center
          end
          @pdf.bounding_box [ 0 , @pleaseVoteHeight ], :width => @pdf.bounds.width do
            @pdf.move_down 10
            @pdf.text bt[:Vote_Both_Sides], :align => :center
          end
        end
      end

      def create_flow_item(item)
        case
        when item.is_a?(Contest) then FlowItem::Contest.new(item)
        when item.is_a?(Question) then FlowItem::Question.new(item)
        when item.is_a?(String) then FlowItem::Header.new(item)
        when item.is_a?(Array) then FlowItem::Combo.new(item)
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

      def empty?
        @column_rects.select{ |r| r.full_height? }.size == @column_rects.size
      end
      
      def make_wide(column, width)
        return nil if column == nil # not an error case
        cols = [column]
        i = @column_rects.index(column) + 1
        total = column.width
        while (total < width && i < @column_rects.size)
          new_col = @column_rects[i]
          @next = @column_rects[i+1]
          total += new_col.width
          cols.push new_col
          i += 1
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

      def init_flow_items
        @flow_items = []
        @precinct.districts(@election.district_set).each do |district|
          header_item = @c.create_flow_item(district.display_name)
          #        @flow_items.push(@c.create_flow_item(district.display_name))
          district.contestsForElection(@election).each do |contest|
            if header_item
              @flow_items.push(@c.create_flow_item( [header_item, @c.create_flow_item(contest)] ))
              header_item = nil
            else
              @flow_items.push(@c.create_flow_item(contest))
            end
          end
          district.questionsForElection(@election).each do |question|
            if header_item
              @flow_items.push(@c.create_flow_item( [header_item, @c.create_flow_item(question)] ))
              header_item = nil
            else
              @flow_items.push(@c.create_flow_item(question))
            end
          end
        end       
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

        init_flow_items
        render_everything
      end

      # initializes everything outside of the flow rect on a new page
      def start_page
        end_page(false) if @page
        @pagenum += 1
        @pdf.start_new_page

        flow_rect = Rect.create_bound_box(@pdf.bounds)
        @c.render_frame flow_rect
        @c.render_header flow_rect

        columns = @c.create_columns(flow_rect)
        # make space for continuation box
        continuation_box = @c.create_continuation_box
        columns.last.bottom += continuation_box.height(@c, columns.last, true)
        @c.render_column_instructions(columns, @pagenum)
        curr_column = columns.next

        @page = { :continuation_box => continuation_box, :columns => columns, :last_column => curr_column }
        [flow_rect, columns, curr_column]
      end

      def end_page(last_page)
        return if @page == nil
        continuation_col = @page[:last_column]
        return if continuation_col == nil
        continuation_box = @page[:continuation_box]
        columns = @page[:columns]
        if (continuation_col.height < 
          continuation_box.height(@c, continuation_col, @flow_items.size != 0) )
          if ! (continuation_col.class == WideColumn && continuation_col.index(columns.last))
            continuation_col = columns.last
          end
        end
        continuation_box.draw(@c, continuation_col, last_page)
        @c.page_complete(@pagenum, last_page)
        @page = nil
      end

      # tries to fit current item into any columns on the current page
      # returns nil if item does not fit
      #
      def fit_width(item, flow_rect, curr_column, columns)
        return nil if curr_column == nil
        if item.min_width != 0 # if width >= narrow column
          if item.min_width > curr_column.width
            if curr_column.full_height?
              curr_column = columns.make_wide curr_column, item.min_width # widen the current column
            else
              curr_column = columns.make_wide columns.next, item.min_width # 
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
        curr_column
      end

      def render_error(text)
        @pdf.fill_color "FF0000"
        @pdf.font "Helvetica", :size => 18, :style => :bold
        @pdf.text_box text, :at => [50, @pdf.bounds.top - 100], :width    => 300, :height => 1000
      end
      
      def render_everything
        @pagenum = 0
        @page =  nil
        curr_column = nil   # used as a flag that we need a new page
        while @flow_items.size > 0
          flow_rect, columns, curr_column = start_page if curr_column == nil
          item = @flow_items.first
          curr_column = fit_width(item, flow_rect, curr_column, columns)
          
          if curr_column == nil # item too wide for current page, start a new one
            if columns.empty? # too wide for empty page, that's an error
              @flow_items.shift
              render_error "ERROR Item #{item.to_s} is too wide to fit onto page."
            end
            next
          end
          
          if item.fits @c, curr_column
            @page[:last_column] = curr_column
            @flow_items.shift.draw @c, curr_column
          elsif curr_column.full_height? # item is taller than a single column, need to break it up
            if curr_column.first != columns.first # split items go on a brand new page for now
              curr_column = nil
              next
            else
              @page[:last_column] = curr_column
              @flow_items.shift
              item.draw @c, curr_column do
                # returns new columns for item to draw in
                curr_column = columns.next
                curr_column = fit_width(item, flow_rect, curr_column, columns)
                if (curr_column == nil)
                  flow_rect, columns, curr_column = start_page
                  curr_column = fit_width(item, flow_rect, curr_column, columns)
                  if (curr_column == nil) # cannot fit on a single blank page, error
                    render_error "ERROR, item #{item.to_s} too wide to fit onto page"
                  end
                end
                @page[:last_column] = curr_column if curr_column
                curr_column
              end # block
            end
          else
            curr_column = columns.next
          end
        end
        end_page(true)
      end

    end

    def self.create(election, precinct, style='default', lang='en')
      Prawn.debug = true
      config = TTV::PDFBallotStyle.get_ballot_config(style, lang)
      renderer = Renderer.new(election, precinct, config)
      renderer.render
      config.bt.save
      renderer.to_s
    end
  end
end
