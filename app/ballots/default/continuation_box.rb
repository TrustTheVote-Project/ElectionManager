require 'ballots/default/ballot_config'


module DefaultBallot
  class ContinuationBox
    def initialize(pdf)
      @pdf = pdf
    end

    def height(config, rect, last_page = false)
      r = rect.clone;
      @pdf.transaction do
        draw(config, r, last_page)
        @pdf.rollback
      end
      rect.top - r.top
    end

    def draw(config, rect, last_page)
      top = rect.top
      @pdf.font "Helvetica", :size => 10, :style => :bold
      unless last_page
        circle_width = 20
        text_height = 0
        text_width = rect.width - circle_width - 8
        @pdf.bounding_box [rect.left+FlowItem::HPAD, rect.top], :width => text_width do
          @pdf.move_down FlowItem::VPAD
          @pdf.text config.bt[:Continue_voting_next_side], :align => :center
          @pdf.move_down FlowItem::VPAD
          text_height = @pdf.bounds.height
        end
        circle_top = rect.top - 6
        @pdf.bounding_box [rect.left + text_width, circle_top ], :width => rect.width - text_width - 8 , :height => circle_width do
          @pdf.circle_at [circle_width / 2, circle_width / 2], :radius => circle_width / 2
          @pdf.fill_color "000000"
          @pdf.fill_and_stroke
          @pdf.stroke_color "FFFFFF"
          @pdf.cap_style :round
          @pdf.line_width 2
          inset = 4
          @pdf.stroke_line [inset, circle_width / 2], [ circle_width - inset, circle_width / 2]
          @pdf.move_to [circle_width / 2, circle_width - inset]
          @pdf.line_to [circle_width - inset, circle_width / 2]
          @pdf.line_to [circle_width / 2, inset]
          @pdf.stroke
        end
        rect.top -= text_height
      else
        @pdf.bounding_box [rect.left + FlowItem::HPAD, rect.top], :width => (rect.width - FlowItem::HPAD2) do
          @pdf.move_down FlowItem::VPAD
          @pdf.text config.bt[:Thank_you], :align => :center
          @pdf.move_down FlowItem::VPAD
          rect.top -= @pdf.bounds.height
        end
      end
      @pdf.line_width 0.75
      @pdf.stroke_color "000000"
      @pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
      @pdf.stroke_line [rect.right, rect.top], [rect.right, top]
      @pdf.stroke_line [rect.left, rect.top], [rect.left, top]
    end
  end


end
