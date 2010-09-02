require 'ttv/abstract_ballot.rb'
require 'ballots/default/ballot_config'
require 'prawn'

module DCBallot
  include ::AbstractBallot

  class BallotConfig < DefaultBallot::BallotConfig
    
    def initialize(election, template)
      @template = template      
      @page = @template.page
      @frame = @template.frame
      @contents = @template.contents

      # to get renderer working
      super(election, template)
    end
    
    def setup(pdf, precinct)
      @pdf = pdf
      @pdf.form if @template.pdf_form
    end

    # Draw the frame around the edges of the page. This frame MAY have
    # a border and MAY, mostly likely will, have content for one of more
    # edges,(top, right, bottom, left), of the page's frame.
    #
    # page_rect - Rectangle that represents the page bounding box
    #
    # returns - Rectangle that is used to contain the main part of the
    # page, where header, body and footer live.
    def render_frame(page_rect)
      # page_rect: rect for the entire page built from the page bounding box

      draw_frame_border(page_rect) do 
        draw_frame_contents do

          # Change the page_rect to be the size of ballot contents,
          # i.e. container for ballot header/footer and columns
          page_rect.top -= (@frame[:margin][:top] + @frame[:border][:width] + @frame[:content][:top][:width])
          page_rect.right -= (@frame[:margin][:right] + @frame[:border][:width] + @frame[:content][:right][:width])
          page_rect.bottom += (@frame[:margin][:bottom] + @frame[:border][:width] + @frame[:content][:bottom][:width])
          page_rect.left += (@frame[:margin][:left] + @frame[:border][:width] +@frame[:content][:left][:width])
        
          # reset the page rect's original_top as it's used to calculate fit of
          # containing items
          page_rect.original_top =  page_rect.top
        end
      end
      page_rect
    end
    
    # Draw the main part of the page. This will have a header, body
    # (where contests/questions are placed), and a footer
    #
    # contents_rect - Rectangle returned by the above render_frame
    # method that will contain the header, body and footer.
    #
    # returns - Rectangle that is used to contain all flow items such
    # (contest flow item, question flow item,...)
    def render_contents(contents_rect)
      flow_rect = nil 
      @pdf.bounding_box [contents_rect.left, contents_rect.top], :width => contents_rect.width, :height => contents_rect.height do
        
        if @contents[:border]
          # draw the contents border
          orig_color = @pdf.stroke_color
          dash unless @contents[:border][:style] = :solid
          @pdf.stroke_color @contents[:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_color
          undash unless @contents[:border][:style] = :solid
        end
        
        draw_header(contents_rect)
        
        # This will also generate the rectangle used to draw all the
        # flow items, (contest flow items, question flow items, ...)
        flow_rect = draw_body(contents_rect)

        # drawing the footer is optional
        draw_footer(contents_rect) if @contents[:footer]

      end
      flow_rect
    end

    # HACK to get renderer to work
    def render_header(flow_rect)
      new_flow_rect = render_contents(flow_rect)
    end
    
    private

    # Draw the border for frame. 
    def draw_frame_border(page_rect)
      # draw the frame border
      # remember frame margin surrounds frame border, frame border
      # surrounds frame content
      
      x = @frame[:margin][:left]
      y = page_rect.top - @frame[:margin][:top]
      w = page_rect.width - @frame[:margin][:left] - @frame[:margin][:right]
      h = page_rect.top - @frame[:margin][:top] - @frame[:margin][:bottom]

      @pdf.bounding_box([x,y], :width => w, :height => h) do      

        if @frame[:border]
          # draw the frame border
          orig_color = @pdf.stroke_color
          dash unless @frame[:border][:style] = :solid
          @pdf.stroke_color @frame[:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_color
          undash unless @frame[:border][:style] = :solid
        end
        
        yield if block_given?
      end
    end

    # Invoke the Procs that will draw the content for the top, right,
    # bottom and left sides of the frame
    def draw_frame_contents

      @frame[:content][:top][:graphics].call(@pdf) if  @frame[:content][:top][:graphics]
      @frame[:content][:right][:graphics].call(@pdf) if  @frame[:content][:right][:graphics]
      @frame[:content][:bottom][:graphics].call(@pdf) if @frame[:content][:bottom][:graphics]
      @frame[:content][:left][:graphics].call(@pdf) if @frame[:content][:left][:graphics]
      
      yield if block_given?
    end
    
    # TODO: DRY up draw code, lots of duplication
    def draw_header(contents_rect)

      x = @pdf.bounds.left + @contents[:header][:margin][:left]
      y = @pdf.bounds.top -  @contents[:header][:margin][:top]
      w = (@pdf.bounds.width * @contents[:header][:width]) - (@contents[:header][:margin][:left] +  @contents[:header][:margin][:right])
      h = (@pdf.bounds.height * @contents[:header][:height]) -  (@contents[:header][:margin][:top] +  @contents[:header][:margin][:bottom])

      # update the top of the contents rect
      contents_rect.top = y - h

      @pdf.bounding_box [x, y], :width => w, :height => h do

        if @contents[:header][:border]
          # draw the header border
          orig_color = @pdf.stroke_color
          dash unless @contents[:header][:border][:style] = :solid
          @pdf.stroke_color @contents[:header][:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_color
          undash unless @contents[:header][:border][:style] = :solid
        end
        
        # draw the header text
        @contents[:header][:graphics].call(@pdf) if @contents[:header][:graphics]
      end
    end
    
    def draw_body(contents_rect)
      #
      new_flow_rectangle = nil
      
      x = @pdf.bounds.left + @contents[:body][:margin][:left]
      y = contents_rect.top -  @contents[:body][:margin][:top]
      w = (@pdf.bounds.width * @contents[:body][:width]) - (@contents[:body][:margin][:left] +  @contents[:body][:margin][:right])
      h = (@pdf.bounds.height * @contents[:body][:height]) -  (@contents[:body][:margin][:top] +  @contents[:body][:margin][:bottom])
      # update the top of the contents rect
      contents_rect.top = y - h
      # top, left, bottom, right
      @pdf.bounding_box [x, y], :width => w, :height => h do

        if @contents[:body][:border]
          # draw the body border
          dash unless @contents[:body][:border][:style] = :solid
          orig_stroke_color = @pdf.stroke_color
          @pdf.stroke_color = @contents[:body][:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_stroke_color
          
          undash unless @contents[:body][:border][:style] = :solid
        end
        
        # draw the body text
        @contents[:body][:graphics].call(@pdf) if @contents[:body][:graphics]
        
        # new flow rectangle
        new_flow_rectangle = AbstractBallot::Rect.new(@pdf.bounds.absolute_top - @page[:margin][:top], @pdf.bounds.absolute_left- @page[:margin][:left], @pdf.bounds.absolute_bottom - @page[:margin][:bottom] , @pdf.bounds.absolute_right- @page[:margin][:right])

      end
      new_flow_rectangle
    end

    def draw_footer(contents_rect)
      
      x = @pdf.bounds.left + @contents[:footer][:margin][:left]
      y = contents_rect.top -  @contents[:footer][:margin][:top]
      w = (@pdf.bounds.width * @contents[:footer][:width]) - (@contents[:footer][:margin][:left] +  @contents[:footer][:margin][:right])
      h = (@pdf.bounds.height * @contents[:footer][:height]) -  (@contents[:footer][:margin][:top] +  @contents[:footer][:margin][:bottom])
      
      @pdf.bounding_box [x, y], :width => w, :height => h do

        if @contents[:footer][:border]
          # draw the body border
          dash unless @contents[:footer][:border][:style] = :solid
          orig_stroke_color = @pdf.stroke_color
          @pdf.stroke_color = @contents[:footer][:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_stroke_color
          
          undash unless @contents[:footer][:border][:style] = :solid
        end
        
        # draw the footer text
        @contents[:footer][:graphics].call(@pdf) if @contents[:footer][:graphics]
      end
    end
    
  end

end
