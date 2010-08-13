require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem

    class Question < FlowItem

      def min_width
        return 300 if @item.question.length > 100
        return ANY_WIDTH
      end

      def draw(config, rect)
        reset_ballot_marks
        top = rect.top
        config.pdf.bounding_box([rect.left+2, rect.top], :width => rect.width - 4) do
          config.pdf.font "Helvetica", :size => 10, :style => :bold
          config.pdf.move_down VPAD
          config.pdf.text config.et.get(@item, :display_name), :leading => 1 #header
          config.pdf.move_down VPAD
          config.pdf.text config.short_instructions(@item), :leading => 1
          config.pdf.move_down VPAD * 2
          config.pdf.font "Helvetica", :size => 10
          config.pdf.text config.et.get(@item, :question), :leading => 1 # question
          rect.top -= config.pdf.bounds.height
        end
        rect.top -= 3
        space, location = config.draw_checkbox rect, config.bt[:Yes]
        add_ballot_mark @item, "Yes", config.pdf.page_number, location
        rect.top -= 3
        space, location = config.draw_checkbox  rect, config.bt[:No]
        add_ballot_mark @item, "No", config.pdf.page_number, location
        config.pdf.line_width 0.5
        rect.top -= 3
        config.frame_item rect, top
      end
    end
    
  end
end
