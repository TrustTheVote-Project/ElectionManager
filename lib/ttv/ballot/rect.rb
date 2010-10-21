module TTV
  module Ballot
    class Rect
      attr_accessor :top, :left, :bottom, :right, :original_top
      attr_accessor :header # true if this column rectangle includes a header item

      def initialize(top, left, bottom, right)
        @top, @left, @bottom , @right = top, left, bottom, right
        @original_top = @top
        @header = false
      end
      
      def header?
        @header
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
  end # end Ballot module
end # end TTV module
