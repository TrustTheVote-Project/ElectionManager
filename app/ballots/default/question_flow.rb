require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem

    class Question < FlowItem

      def initialize(pdf, question, scanner, options={ })
        raise ArgumentError, "pdf should be a Prawn::Document" unless pdf.is_a?(::Prawn::Document)
        raise ArgumentError, "question should be be Question" unless question.is_a?(::Question)
        @pdf = pdf
        @question = question
        super(@question, scanner)
      end
      
      def min_width
        return 300 if @question.question.length > 100
        return ANY_WIDTH
      end
      
      def short_instructions
        @pdf.text "Vote yes or no", :leading => 1        
      end
      
      def header(rect)
        @pdf.bounding_box([rect.left+2, rect.top], :width => rect.width - 4) do
          @pdf.font "Helvetica", :size => 10, :style => :bold
          @pdf.move_down VPAD
          @pdf.text @question.display_name, :leading => 1 #header
          @pdf.move_down VPAD

          short_instructions
          @pdf.move_down VPAD * 2
          @pdf.font "Helvetica", :size => 10
          @pdf.text @question.question, :leading => 1 # question
          rect.top -= @pdf.bounds.height
        end
      end
      
      def draw(config, rect)
        ballot_marks = []
        top = rect.top
        header(rect)
        rect.top -= 3
        space, location = config.draw_checkbox rect, "Yes"
        ballot_marks << TTV::BallotMark.new(@question,"Yes", @pdf.page_number, location)
        rect.top -= 3
        space, location = config.draw_checkbox  rect, "No" #config.bt[:No]
        ballot_marks << TTV::BallotMark.new(@question,"No", @pdf.page_number, location)
        @pdf.line_width 0.5
        rect.top -= 3
        config.frame_item rect, top
      end
    end
    
  end
end
