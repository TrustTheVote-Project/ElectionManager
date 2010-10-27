module TTV
  module Ballot
    # encapsulates columns for rendering
    class Columns
      def initialize(col_count, flow_rect)
        @column_rects = []
        column_width = flow_rect.width / ( col_count * 1.0)
        col_count.times do |x|
          @column_rects.push TTV::Ballot::Rect.create_wh(flow_rect.top, flow_rect.left + column_width *x,
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
        return TTV::Ballot::WideColumn.new(cols) if total >= width
        nil
      end      
    end

  end # end Ballot module
end # end TTV module
