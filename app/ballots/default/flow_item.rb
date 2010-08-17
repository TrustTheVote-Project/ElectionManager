require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem

    ANY_WIDTH = 1
    HPAD = 3
    HPAD2 = 6
    VPAD = 3
    VPAD2 = 6

    def initialize(item, scanner)
      @item = item
      @scanner = scanner
    end

    def reset_ballot_marks
      @ballot_marks = []
    end
    
    def ballot_marks
      @ballot_marks || []
    end
    
    def fits(config, rect)
      # clever way to see if we fit, avoiding code duplication for measure vs. draw
      # Algorithm: draw the item. If it overflows flow rectangle, it does not fit.
      r = rect.clone
      config.pdf.transaction do
        draw(config, r)
        config.pdf.rollback
      end
      r.height > 0
    end

    def min_width
      0
    end

    def to_s
      @item.to_s
    end

  end # end FlowItem
  
end
