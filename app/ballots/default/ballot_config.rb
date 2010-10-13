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

    attr_accessor :pdf, :page_size, :page_layout, :left_margin, :right_margin, :top_margin, :bottom_margin, :columns, :scanner, :template, :precinct, :template, :election

    CHECKBOX_WIDTH = 22
    CHECKBOX_HEIGHT = 10
    HPAD = 3
    HPAD2 = 6
    VPAD = 3

#    def initialize(style, lang, election, scanner,
    #    instruction_text_url)
    def initialize(election, template)

      style = BallotStyle.find(template.ballot_style).ballot_style_code
      @lang = Language.find(template.default_language).code
      @instruction_text_url = template.instructions_image.url
      @scanner = TTV::Scanner.new
      
      @template = template
      
      @file_root = "#{RAILS_ROOT}/app/ballots/#{style}"
      @election = election
      @ballot_translation = PDFBallotStyle.get_ballot_translation(style, @lang)
      @election_translation = PDFBallotStyle.get_election_translation(election, @lang)
      #@instruction_text_url = instruction_text_url
      
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
      @pdf.form if @template.pdf_form
      
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

    def stroke_checkbox(pt = [0,0], name="")
      @pdf.line_width 1.5
      @pdf.fill_color "FFFFFF"
      @pdf.stroke_color "000000"
      @pdf.rectangle pt, CHECKBOX_WIDTH, CHECKBOX_HEIGHT
      @pdf.fill_and_stroke
      @pdf.fill_color "000000"
    end
    
    
    # drow the checkbox to the left of the text.
    def xxdraw_checkbox(rect, text)
      # rect is either an enclosing column or combo box flow.
      
      # draw the checkbox in a bounding box within the rect.
      #      x = rect.left + (FlowItem::HPAD2*2)
      x = rect.left + FlowItem::HPAD2*2
      y = rect.top
      puts "x, y = #{x}, #{y}"
      
      # space btw the checkbox and the text. "<checkbox><horiz_space><text>"
      horiz_space = CHECKBOX_WIDTH + (FlowItem::HPAD2*2)
      
      @pdf.bounding_box [x, y], :width => rect.width - horiz_space do
        puts "draw_checkbox bounds is "
        TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)
        @pdf.form? ? stroke_checkbox([0,0]) : stroke_checkbox([x,y]) 
      end
      
      
      # draw the text in a bounding box to the rigth of the checkbox. 
      @pdf.bounding_box [rect.left + horiz_space, rect.top], :width => rect.width - horiz_space do
        @pdf.font "Helvetica", :size => 10
        @pdf.text text
        # this will decrease the enclosing column/combo box top by
        # height of text bounding box or checkbox height
        rect.top -= [@pdf.bounds.height, CHECKBOX_HEIGHT].max
      end      
      
      location  = [1,5] # dummy location to make things work
      return horiz_space, location
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
    
    # TODO: refactor
    def render_frame(flow_rect)
      bar_width = 18
      bar_height = 140

      # TODO: remove as this, effectively, does nothing.
      # all it does is fill of empty space. Add a '\f\n' pdf primitive
      @scanner.render_grid(@pdf)
      
      # TODO: remove this. Only used for the grid system that is no
      # longer needed.
      # draws the long black rectangles around the edges of the doc
      @scanner.render_ballot_marks(@pdf)

      # bounding box at:
      # x, y, w, h = 0, 737.0, 576.0, 672.0
      x = 0
      y =  @pdf.bounds.height - @pleaseVoteHeight + 35
      w = @pdf.bounds.width
      h = @pdf.bounds.height - @pleaseVoteHeight * 2
      # puts "render_frame: x, y, w, h = #{x}, #{y}, #{w}, #{h}"
      @pdf.bounding_box [x,y], :width => w, :height => h do

        # puts "render_frame:"
        # TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)
        # Bounds coordinates "t, r, b, l" = "672.0, 576.0, 0, 0"
        # TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)
        # Absolute Bounds coordinates "t, r, b, l" = "767.0, 594.0,
        # 95.0, 18"

        
        # draw a rectangle at:
        # x, y, w, h = 26, 672.0, 524.0, 672.0
        # This draws the frame around the header and contents of the
        # doc
        x = bar_width + @padding
        y = @pdf.bounds.height
        w = @pdf.bounds.width - (bar_width + @padding)*2
        h = @pdf.bounds.height
        # puts "render_frame: x, y, w, h = #{x}, #{y}, #{w}, #{h}"
        @pdf.stroke_rectangle([x, y], w, h)

        # draws the below vertically up the left/right side of doc
        @pdf.font "Courier", :size => 14
        @pdf.draw_text bt[:Sample_Ballot], :at => [16, 275], :rotate => 90
        @pdf.draw_text bt[:Sample_Ballot], :at => [@pdf.bounds.right - 2 , 275], :rotate => 90
        @pdf.draw_text "12001040100040", :at => [16, 410], :rotate => 90
        @pdf.draw_text "132301113", :at => [@pdf.bounds.right - 2, 146], :rotate => 90
        
        # need to add 5 points to the bottom of the flow_rect to get
        # it align with the bottom of the frame?
        horiz_delta = bar_width + @padding
        vert_delta =  (@pleaseVoteHeight*2)+5
        
        # puts "flow_rect before = #{flow_rect}"
        # flow_rect before = emptyT:732.0 L:0 B:0 R:576.0 W:576.0 H:732.0
        # puts "render_frame: decrease flow_rect by horiz, vert = #{horiz_delta}, #{vert_delta}"
        # render_frame: decrease flow_rect by horiz, vert = 26, 65
        flow_rect.inset horiz_delta, vert_delta
        # puts "flow_rect after = #{flow_rect}"
        # flow_rect after = T:667.0 L:26 B:65 R:550.0 W:524.0 H:602.0
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
        if instructions?
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
        @pdf.bounding_box [0, @pdf.bounds.height-5 ], :width => @pdf.bounds.width do
          @pdf.text bt[:Vote_Both_Sides], :size => 10,:align => :center
        end
        @pdf.bounding_box [ 0 , @pleaseVoteHeight ], :width => @pdf.bounds.width do
          @pdf.move_down 10
          @pdf.text bt[:Vote_Both_Sides], :size => 10, :align => :center
        end
      end
    end

    
    def instructions?
     !@instruction_text_url.blank? && !@instruction_text_url.include?('missing')
    end
  end

end
