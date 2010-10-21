
module TTV
  module Ballot
    # WideColumn is used in layout to group columns together
    # its boundaries are leftmost/rightmost/lowest top/highest bottom
    class WideColumn

      attr_accessor :header # true if this column rectangle includes a
      # header item

      def initialize (rects)
        @rects = rects
        @original_top = top
      end

      def header?
        @header
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
  end # end Ballot module
end # end TTV module
