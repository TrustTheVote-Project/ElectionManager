#
# DefaultBallot is is used to layout and render the most basic ballot. It's the first one we implemented.
# The "include AbstractBallot" makes the DefaultBallot module sort of inherit form the AbstractBallot module. Any methods not definedf
# here are defined in AbstractBallot.


require 'ttv/abstract_ballot.rb'
require 'prawn'

require 'ballots/default/combo_flow'
require 'ballots/default/header_flow'
require 'ballots/default/question_flow'
require 'ballots/default/contest_flow'
require 'ballots/default/continuation_box'
require 'ballots/default/flow_item'

module DefaultBallot
  include ::AbstractBallot

  class BallotConfig

    attr_accessor :pdf, :page_size, :page_layout, :left_margin, :right_margin, :top_margin, :bottom_margin, :columns, :scanner

    CHECKBOX_WIDTH = 22
    CHECKBOX_HEIGHT = 10
    HPAD = 3
    HPAD2 = 6
    VPAD = 3

    def initialize(style, lang, election, scanner, instruction_text_url)
      @file_root = "#{RAILS_ROOT}/app/ballots/#{style}"
      @election = election
      @lang = lang
      @ballot_translation = PDFBallotStyle.get_ballot_translation(style, lang)
      @election_translation = PDFBallotStyle.get_election_translation(election, lang)
      @instruction_text_url = instruction_text_url
    
      @page_size = "LETTER"
      @page_layout = :portrait
      @left_margin = @right_margin = 18
      @top_margin = @bottom_margin = 30
      @pleaseVoteHeight = 30
      @padding = 8
      @columns = @columns || 3
      @checkbox_orientation = @checkbox_orientation || :left 
      @scanner = scanner
      @scanner.set_checkbox(CHECKBOX_WIDTH, CHECKBOX_HEIGHT, @checkbox_orientation)
    end

    def setup(pdf, precinct)
      @pdf = pdf
      @precinct = precinct
      if @lang == "zh"  # chinese fonts, 
        pdf.font_families.update({
        "Helvetica" => { :normal => "#{Rails.root}/fonts/Arial Unicode.ttf",
                         :bold => "#{Rails.root}/fonts/Arial Unicode.ttf" },
        "Courier" => { :normal => "#{Rails.root}/fonts/Arial Unicode.ttf" }
        })
        @wrap = :character
      else
        pdf.font_families.update({
          "Helvetica" => { :normal => "#{Rails.root}/fonts/Arial Unicode.ttf",
                           :bold => "#{Rails.root}/fonts/Arial Bold.ttf" },
          "Courier" => { :normal => "#{Rails.root}/fonts/Courier New.ttf" }
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
      AbstractBallot::Columns.new(@columns, flow_rect)
    end

    def short_instructions(item)
      if item.is_a?(Contest)
        if item.voting_method_id == VotingMethod::WINNER_TAKE_ALL.id
          return bt[:Vote_for_1].sub("&1;", "1") if item.open_seat_count < 2
          return bt[:Vote_for_many].sub("&1;", item.open_seat_count.to_s)
        else
          return bt[:Rank_candidates]
        end
      elsif item.is_a?(Question)
        return bt[:Vote_yes_or_no]
      else
        raise "Unknown short instruction type #{item.class}"
      end      
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
#      @pdf.bounding_box [rect.left + FlowItem::HPAD2, rect.top], :width => CHECKBOX_WIDTH do
#        stroke_checkbox
#      end
      check_top_left, location = @scanner.align_checkbox(@pdf, [rect.left + FlowItem::HPAD2, rect.top])
      stroke_checkbox check_top_left
#      @pdf.bounding_box check_top_left.dup, :width => CHECKBOX_WIDTH do
#        @pdf.fill_color "FF0000"
#        @pdf.rectangle [0,0], CHECKBOX_WIDTH, CHECKBOX_HEIGHT
#        @pdf.fill_and_stroke
#        @pdf.fill_color "000000"
#      end
      rect.top -= rect.top - check_top_left[1]
#      spacer = 2 * FlowItem::HPAD2 + CHECKBOX_WIDTH
      spacer = check_top_left[0] - rect.left + CHECKBOX_WIDTH + FlowItem::HPAD2
      @pdf.bounding_box [rect.left + spacer, rect.top], :width => rect.width - spacer do
        @pdf.font "Helvetica", :size => 10
        @pdf.text text
        rect.top -= [@pdf.bounds.height, CHECKBOX_HEIGHT].max
      end
      return spacer, location  # returns left-hand side of text position
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
      @scanner.render_grid(@pdf)
      @scanner.render_ballot_marks(@pdf)
      @pdf.bounding_box [0, @pdf.bounds.height - @pleaseVoteHeight + 35], :width => @pdf.bounds.width, :height => @pdf.bounds.height - @pleaseVoteHeight * 2 do

        @pdf.stroke_rectangle [bar_width + @padding,@pdf.bounds.height], 
        @pdf.bounds.width - (bar_width + @padding)* 2, @pdf.bounds.height
        @pdf.font "Courier", :size => 14
        @pdf.draw_text bt[:Sample_Ballot], :at => [16, 275], :rotate => 90
        @pdf.draw_text bt[:Sample_Ballot], :at => [@pdf.bounds.right - 2 , 275], :rotate => 90
        @pdf.draw_text "12001040100040", :at => [16, 410], :rotate => 90
        @pdf.draw_text "132301113", :at => [@pdf.bounds.right - 2, 146], :rotate => 90
        # need to add 5 points to the bottom of the flow_rect to get
        # it align with the bottom of the frame?
        flow_rect.inset bar_width + @padding, (@pleaseVoteHeight*2)+5
      end
    end

    def render_header(flow_rect)
      @pdf.font "Helvetica", :size => 13,  :style => :bold
      @pdf.bounding_box [flow_rect.left + @padding, flow_rect.top], 
      :width => flow_rect.width - @padding do
        @pdf.move_down 3
        @pdf.text bt[:OFFICIAL_BALLOT]
        @pdf.text et.strftime(@election.start_date, "%B %d, %Y")
        @pdf.bounding_box [@pdf.bounds.width / 3,  @pdf.bounds.height], 
        :width => @pdf.bounds.width * 2 / 3 do
          @pdf.move_down 3
          @pdf.text et.get(@election, :display_name), :align => :center
          @pdf.text et.get(@precinct, :display_name), :align => :center
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
      @pdf.bounding_box( [rect.left + @padding, rect.top], 
                        :width => rect.width - @padding * 2) do
        @pdf.move_down 3
        unless @instruction_text_url.index("missing")
          @pdf.image "#{RAILS_ROOT}/public/#{@instruction_text_url}", :width => 172, :height => 600, :at =>[-6,+2] #need to move sizes into style template?
        end
      end
      rect.top = rect.bottom
      @pdf.line_width 0.5
      #@pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
     # @pdf.stroke_line [rect.right, rect.top], [rect.right, top]
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
      when item.is_a?(Contest) then FlowItem::Contest.new(item, @scanner)
      when item.is_a?(Question) then FlowItem::Question.new(item, @scanner)
      when item.is_a?(String) then FlowItem::Header.new(item, @scanner)
      when item.is_a?(Array) then FlowItem::Combo.new(item)
      end
    end
    
    def instructions?
     !@instruction_text_url.blank? && !@instruction_text_url.include?('missing')
    end
  end

end
