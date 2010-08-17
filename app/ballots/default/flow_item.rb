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
    
    def add_ballot_mark(contest, choice, page, location)
      @ballot_marks.push(@scanner.create_ballot_mark contest, choice, page, location )
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

    def draw(config, rect)
      # debug only code, never executed
      top = rect.top
      config.pdf.font("Helvetica", :size => 10, :style => :italic)
      config.pdf.bounding_box([rect.left + HPAD, rect.top], :width => rect.width - HPAD ) do
        config.pdf.move_down VPAD
        config.pdf.text "FlowItem.draw"
        rect.top -= config.pdf.bounds.height
      end
      config.pdf.stroke_line [rect.left, rect.top], [rect.right, rect.top]
      config.pdf.stroke_line [rect.right, rect.top], [rect.right, top]
    end

    def min_width
      0
    end

    def to_s
      @item.to_s
    end

  end # end FlowItem
  
end
