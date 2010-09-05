require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem
    
    # TODO: change from inner class to class within the Flow module
    class Header < FlowItem
      
      def initialize(pdf, text, scanner, options={ })
        raise ArgumentError, "pdf should be a Prawn::Document" unless pdf.is_a?(::Prawn::Document)
        raise ArgumentError, "text should be a String" unless text.is_a?(String)
        @pdf = pdf
        @text = text
        super(@text, scanner)
      end

      def min_width
        ANY_WIDTH
      end
      
      def display_name
        @text
      end
      
      # Draw header, text and 3 sides of bounding box, within an
      # enclosing column. Will move the top of the enclosing column
      # down by the height of the header text.
      def draw(config, enclosing_column_rect)

        column_top_orig = enclosing_column_rect.top
        config.pdf.font("Helvetica", :size => 10, :style => :bold )
        
        # TODO: make this configurable via ballot style template
        orig_color = config.pdf.fill_color
        config.pdf.fill_color('808080')
        config.pdf.fill_rectangle([enclosing_column_rect.left, enclosing_column_rect.top], enclosing_column_rect.width, VPAD + config.pdf.height_of(@text))
        config.pdf.fill_color(orig_color)

        # bounding box is the document at this point
        # Bounds coordinates "t, r, b, l" = "732.0, 576.0, 0, 0"
        #TTV::Prawn::Util.show_bounds_coordinates(config.pdf.bounds)
        
        config.pdf.bounding_box([enclosing_column_rect.left + HPAD, enclosing_column_rect.top], :width => enclosing_column_rect.width - HPAD * 2) do
          
          # created a new bounding box.
          # Bounds coordinates "t, r, b, l" = "0.0, 194, 0, 0"
          #TTV::Prawn::Util.show_bounds_coordinates(config.pdf.bounds)
          
          config.pdf.move_down VPAD
          
          # The @item is always just a Ruby String
          config.pdf.text @text, :leading => 1
          

          # bounding box is increased the height of header text, 14.87 pts
          # Bounds coordinates "t, r, b, l" = "14.87, 194, 0, 0"
          # TTV::Prawn::Util.show_bounds_coordinates(config.pdf.bounds)

          # decrease the top of the enclosing column by the height of
          # the header text.
          enclosing_column_rect.top -= config.pdf.bounds.height

        end

        # draw/stroke 3 lines for the header bounding box:
        # bottom_line - across at enclosing_column_rect.top
        # left_line and right lines - up from enclosing_column_rect.top to column_top_orig
        # no line on top 
        #puts "TGD: enclosing_column = #{enclosing_column_rect.inspect}"
        config.frame_item enclosing_column_rect, column_top_orig
      end
    end
  end
end
