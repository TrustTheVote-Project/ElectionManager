module DefaultBallot
  class FlowItem
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
        reset_ballot_marks
        @flow_items.each { |f| f.draw config, rect, &bloc }
      end
      
      def reset_ballot_marks
        @flow_items.each { |f| f.reset_ballot_marks }
      end
      
      def ballot_marks
        ret = []
        @flow_items.each { |f| ret.concat f.ballot_marks }
        ret
      end

      def to_s
        s = "Combo\n"
        @flow_items.each { |f| s += f.to_s + "\n" }
        s
      end
    end
  end
end
