require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem

    class Question < FlowItem

      def initialize(pdf, question, scanner, options={ })
        raise ArgumentError, "pdf should be a Prawn::Document" unless pdf.is_a?(::Prawn::Document)
        raise ArgumentError, "question should be be Question" unless question.is_a?(::Question)
        @pdf = pdf
        @active = @pdf.form?
        
        @question = question
        
        # question name and id used in field identifiers
        @question_name = @question.display_name.gsub(/\s+/,'_')
        @question_ident = @question.ident.gsub(/\s+/,'_')
        

        super(@question, scanner)
      end
      
      def min_width
        return 300 if @question.question.length > 100
        return ANY_WIDTH
      end
      
      def short_instructions
        @pdf.text "Vote for not more than (1)", :size => 8, :align => :center, :leading => 1        
      end
      
      def header(rect)
        @pdf.bounding_box([rect.left+12, rect.top], :width => rect.width - 16) do

          # TODO: make this configurable via ballot style template
          orig_color = @pdf.fill_color
          @pdf.fill_color('DCDCDC')
          @pdf.fill_rectangle([@pdf.bounds.left-12, @pdf.bounds.top], rect.width,  @pdf.height_of(@question.display_name)+18)
          @pdf.fill_color(orig_color)

          @pdf.font "Helvetica", :size => 10, :style => :bold
          @pdf.move_down VPAD
          #@pdf.text "Proposed Constitutional Amendment " + @question.display_name, :align => :center, :leading => 1 #header
          @pdf.text @question.display_name, :align => :center, :leading => 1 #header
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
        cb_width = 22
        cb_height = 10
        
        top = rect.top
        
        header(rect)
        rect.top -= 3        
        
        if @active
          # TODO: refactor the below into it's own method
          # using the ballot styles
          # draw a radio group for Yes and No 
          @pdf.draw_radio_group(@question_ident, :at => [ 0,0], :width => 10, :height => 10) do |radio_group|
            
            # bounding box for Yes selection, radio button and "Yes" text
            @pdf.bounding_box([rect.left+12, rect.top], :width => rect.width) do

              # Draw radio button to select Yes
              @pdf.bounding_box([0,0], :width => cb_width +3) do
                cb_bottom = @pdf.bounds.top-cb_height
                radio_group[:Kids] <<  @pdf.draw_radiobutton("#{@question_ident}_yes", :at => [0,cb_bottom], :width => cb_width, :height => cb_height,:selected => false)
              end
              # Draw "Yes" text
              #   @pdf.bounding_box([cb_width + (HPAD*3),0], :width => 20 ) do
              # TODO: hack for DC
              @pdf.bounding_box([cb_width + (HPAD*3),0], :width => 220 ) do

                @pdf.text("FOR Charter Amendment")
                # @pdf.text("Yes")
              end
              rect.top -= @pdf.bounds.top
            end # end "Yes" selection

            # TODO:
            # VPAD not found here, prob a scope issue with radio
            # group, not seeing FlowItem constants
            # rect.top -= (VPAD *2)
             rect.top -= 8
            
            # bounding box for No selection, radio button and "Yes" text
            @pdf.bounding_box([rect.left+12, rect.top], :width => rect.width) do
                
                # Draw radio button to select No
                @pdf.bounding_box([0,0], :width => cb_width +3) do
                   cb_bottom = @pdf.bounds.top-cb_height
                  radio_group[:Kids] <<  @pdf.draw_radiobutton("#{@question_ident}_no", :at => [0,cb_bottom], :width => cb_width, :height => cb_height,:selected => false)
              end
              
              # Draw "No" text
              # @pdf.bounding_box([cb_width + (HPAD*3),0], :width =>
       # 20 ) do
              # TODO: hack for DC
              @pdf.bounding_box([cb_width + (HPAD*3),0], :width => 220 ) do

                @pdf.text("AGAINST Charter Amendment")
                # @pdf.text("No")
              end
              
              rect.top -= @pdf.bounds.top
            end # end No selection
          end # end radio group end draw_radio_group
        else

          space, location = config.draw_checkbox rect, "Yes"
          ballot_marks << TTV::BallotMark.new(@question,"Yes", @pdf.page_number, location)
          rect.top -= 3
          space, location = config.draw_checkbox  rect, "No" #config.bt[:No]
          ballot_marks << TTV::BallotMark.new(@question,"No", @pdf.page_number, location)

        end
        @pdf.line_width 0.5
        rect.top -= 3
        config.frame_item rect, top
      end
    end
    
  end
end
