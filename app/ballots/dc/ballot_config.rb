#require 'ttv/abstract_ballot.rb'
require 'ballots/default/ballot_config'
require 'ttv/ballot/rect'

require 'prawn'

module DcBallot
  include ::AbstractBallot

  class BallotConfig < DefaultBallot::BallotConfig
    attr_accessor :page, :frame
    
    def initialize(election, template)
      @template = template
      # to get renderer working
      super(election, template)
      
      @page = @template.page
      @frame = @template.frame
      @contents = @template.contents
      
      # hack to override these geting set in the superclass

      @page_size = @template.page[:size]
      @page_layout = @template.page[:layout]
      @left_margin = @template.frame[:margin][:left]
      @right_margin = @template.frame[:margin][:right]
      @top_margin =  @template.frame[:margin][:top]
      @bottom_margin =  @template.frame[:margin][:bottom]

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

        unless @contents[:border][:width] == 0
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

        unless @frame[:border][:width] == 0
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

    # Invoke the methods that will draw the content for the top, right,
    # bottom and left sides of the frame
    def draw_frame_contents
      template.ballot_rule.frame_content_top(self)
      template.ballot_rule.frame_content_right(self)
      template.ballot_rule.frame_content_bottom(self)
      template.ballot_rule.frame_content_left(self)

      # instance_eval(@frame[:content][:top][:graphics]) if  @frame[:content][:top][:graphics]
      # instance_eval(@frame[:content][:right][:graphics]) if  @frame[:content][:right][:graphics]
      # instance_eval(@frame[:content][:bottom][:graphics]) if @frame[:content][:bottom][:graphics]
      # instance_eval(@frame[:content][:left][:graphics]) if @frame[:content][:left][:graphics]

      yield if block_given?
    end
    
    # TODO: DRY up draw code, lots of duplication
    def draw_header(contents_rect)

      x = @pdf.bounds.left + @contents[:header][:margin][:left]
      y = @pdf.bounds.top -  @contents[:header][:margin][:top]
      
      if @contents[:header][:width] <= 1.0
        # percentage of width
        w = (@pdf.bounds.width * @contents[:header][:width]) - (@contents[:header][:margin][:left] +  @contents[:header][:margin][:right])
      else
        w = @contents[:header][:width]
      end
      if @contents[:header][:height] <= 1.0
        # percentage of height
        h = (@pdf.bounds.height * @contents[:header][:height]) - (@contents[:header][:margin][:top] +@contents[:header][:margin][:bottom])
      else
        h = @contents[:header][:height]
      end
      
      # update the top of the contents rect
      contents_rect.top = y - h

      @pdf.bounding_box [x, y], :width => w, :height => h do

        unless @contents[:header][:border][:width] == 0
          # draw the header border
          orig_color = @pdf.stroke_color
          dash unless @contents[:header][:border][:style] = :solid
          @pdf.stroke_color @contents[:header][:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_color
          undash unless @contents[:header][:border][:style] = :solid
        end
        
        # draw the header text
        template.ballot_rule.contents_header(self)
        # instance_eval(@contents[:header][:graphics]) if @contents[:header][:graphics]
      end
    end
    
    def draw_body(contents_rect)
      #
      new_flow_rectangle = nil
      
      x = @pdf.bounds.left + @contents[:body][:margin][:left]
      y = contents_rect.top -  @contents[:body][:margin][:top]
      
      if @contents[:body][:width] <= 1.0
        # percentage of width
        w = (@pdf.bounds.width * @contents[:body][:width]) - (@contents[:body][:margin][:left] +  @contents[:body][:margin][:right])
      else
        w = @contents[:body][:width]
      end
      if @contents[:body][:height] <= 1.0
        # percentage of height
        # The contents height at this point is the @pdf.bounds.height - the height contents[:header]. 
        h = (contents_rect.height * @contents[:body][:height]) -(@contents[:body][:margin][:top] + @contents[:body][:margin][:bottom])  
      else
        h = @contents[:body][:height]
      end

      # update the top of the contents rect
      contents_rect.top = y - h
      
      # top, left, bottom, right
      @pdf.bounding_box [x, y], :width => w, :height => h do

        unless @contents[:body][:border][:width] == 0
          # draw the body border
          dash unless @contents[:body][:border][:style] = :solid
          orig_stroke_color = @pdf.stroke_color
          @pdf.stroke_color = @contents[:body][:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_stroke_color
          
          undash unless @contents[:body][:border][:style] = :solid
        end
        
        # draw the body text
        template.ballot_rule.contents_body(self)
        #instance_eval(@contents[:body][:graphics]) if @contents[:body][:graphics]
        
        # new flow rectangle
        new_flow_rectangle = TTV::Ballot::Rect.new(@pdf.bounds.absolute_top - @frame[:margin][:top], @pdf.bounds.absolute_left- @frame[:margin][:left], @pdf.bounds.absolute_bottom - @frame[:margin][:bottom] , @pdf.bounds.absolute_right- @frame[:margin][:right])

      end

      new_flow_rectangle
    end

    def draw_footer(contents_rect)
      
      x = @pdf.bounds.left + @contents[:footer][:margin][:left]
      y = contents_rect.top -  @contents[:footer][:margin][:top]
      
      if @contents[:footer][:width] <= 1.0
        # percentage of contents width
        w = (@pdf.bounds.width * @contents[:footer][:width]) - (@contents[:footer][:margin][:left] +  @contents[:footer][:margin][:right])
      else
        w = @contents[:footer][:width]        
      end
      
      if @contents[:footer][:height] <= 1.0
        # percentage of contents height
        h = (@pdf.bounds.height * @contents[:footer][:height]) -  (@contents[:footer][:margin][:top] +  @contents[:footer][:margin][:bottom])
      else
        h = @contents[:footer][:height]
      end
      
      @pdf.bounding_box [x, y], :width => w, :height => h do

        unless @contents[:footer][:border][:width] == 0
          # draw the body border
          dash unless @contents[:footer][:border][:style] = :solid
          orig_stroke_color = @pdf.stroke_color
          @pdf.stroke_color = @contents[:footer][:border][:color]
          @pdf.stroke_bounds
          @pdf.stroke_color orig_stroke_color
          
          undash unless @contents[:footer][:border][:style] = :solid
        end
        
        # draw the footer text
        template.ballot_rule.contents_footer(self)
        # instance_eval(@contents[:footer][:graphics]) if @contents[:footer][:graphics]
      end
    end
    
  end

end
