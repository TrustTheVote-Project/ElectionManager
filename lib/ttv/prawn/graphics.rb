# This module redefines some drawing primitives such as rectangle,
# circle_at and move_to.
# Prawn::Graphics methods builds in offsets in these primitives that are
# not needed inside of when building path construction operators in
# Form XObject streams.

# For Example:

# In the Prawn::Graphics module
#     def rectangle(point,width,height)
#       x,y = map_to_absolute(point)
#       add_content("%.3f %.3f %.3f %.3f re" % [ x, y - height, width, height ])
#     end

# In this TTV::Prawn::Graphics module
#     def rectangle(point, width, height)
#       x, y = point.flatten
#       add_content("%.3f %.3f %.3f %.3f re" % [ x, y, width, height ])
#     end

# This TTV:Prawn::Graphics module's rectangle method does not:
# - call map_to_absolute, which adds the bounding_box's coordinates.
#     def map_to_absolute(*point)
#       x,y = point.flatten
#       [@bounding_box.absolute_left + x, @bounding_box.absolute_bottom + y]
#     end
# - subtract the height from the initial y coordinate
#       add_content("%.3f %.3f %.3f %.3f re" % [ x, y - height, width, height])

# These methods are used, for example, when building path construction operators
# inside of PDF Form XObject streams.    
module TTV
  module Prawn
    module Graphics

      #include Prawn::Graphics
      
      def rectangle(point, width, height)
        # Prawn::Graphics.rectangle((point, width, height)
        # maps the x and y, which I don't want!!
        #x,y = map_to_absolute(point)
        x, y = point.flatten
        add_content("%.3f %.3f %.3f %.3f re" % [ x, y, width, height ])
      end
      
      def line(*points)        
        x0, y0, x1, y1 = points.flatten
        move_to(x0, y0)
        line_to(x1, y1)
      end
      
      def move_to(*point)
        x,y = point.flatten
        add_content("%.3f %.3f m" % [ x, y ])  
      end

      def line_to(*point)
        x, y = point.flatten
        add_content("%.3f %.3f l" % [ x, y ])
      end
      
      def circle_at(point, options)
        x,y = point
        ellipse_at [x, y], options[:radius]
      end

      KAPPA = 4.0 * ((Math.sqrt(2) - 1.0) / 3.0)      
      def ellipse_at(point, r1, r2 = r1)
        x, y = point
        l1 = r1 * KAPPA
        l2 = r2 * KAPPA
        
        move_to(x + r1, y)
        
        # Upper right hand corner
        curve_to [x,  y + r2],
        :bounds => [[x + r1, y + l1], [x + l2, y + r2]]
        
        # Upper left hand corner
        curve_to [x - r1, y],
        :bounds => [[x - l2, y + r2], [x - r1, y + l1]]
        
        # Lower left hand corner
        curve_to [x, y - r2],
        :bounds => [[x - r1, y - l1], [x - l2, y - r2]]
        
        # Lower right hand corner
        curve_to [x + r1, y],
        :bounds => [[x + l2, y - r2], [x + r1, y - l1]]
        
        move_to(x, y)
      end

      def curve_to(dest, options={ })
        options[:bounds] or raise Prawn::Errors::InvalidGraphicsPath,
        "Bounding points for bezier curve must be specified "+
          "as :bounds => [[x1,y1],[x2,y2]]"

        curve_points = (options[:bounds] << dest).map { |e| e }
        add_content("%.3f %.3f %.3f %.3f %.3f %.3f c" %
                    curve_points.flatten )
      end
      
      private
      
      #       def map_to_absolute(*point)
      #         x,y = point.flatten
      #         [x, y]
      #       end
    end
  end
end
