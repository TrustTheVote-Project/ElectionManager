require 'ballots/default/ballot_config'

module DefaultBallot
  class FlowItem
    class Contest < FlowItem

      NAME_WIDTH = 100
      MAX_RANKED = 10
      NEXT_COL_BOUNCE = 30
      
      def initialize(pdf, contest, scanner, options={ })
        opts = { :form_enabled => false}.merge(options)
        raise ArgumentError, "pdf should be a Prawn::Document" unless pdf.is_a?(::Prawn::Document)
        raise ArgumentError, "contest shoulbe be Contest" unless contest.is_a?(::Contest)
        @pdf = pdf
        @contest = contest
        super(@contest, scanner)
      end
      
      def min_width
        if @contest.voting_method_id == VotingMethod::WINNER_TAKE_ALL.id
          super
        else
          100 + 3 * HPAD + [@contest.candidates.count, MAX_RANKED].min * (HPAD + BallotConfig::CHECKBOX_WIDTH)
        end
      end
      
      def short_instructions
        short_instr = if @contest.voting_method_id == VotingMethod::WINNER_TAKE_ALL.id

                        @contest.open_seat_count < 2 ? "Vote for 1" : "Vote for up to #{@contest.open_seat_count}"
                      else
                        "Rank the candidates"
                      end
        
        @pdf.text short_instr, :leading => 1
      end
      

      def header(rect)
        @pdf.bounding_box [rect.left+HPAD, rect.top], :width => rect.width - HPAD2 do
          @pdf.font "Helvetica", :size => 10, :style => :bold
          @pdf.move_down VPAD
          @pdf.text @contest.display_name, :leading => 1 #header
          @pdf.move_down VPAD
          short_instructions
          rect.top -= @pdf.bounds.height
        end
      end
      
      def draw(config, rect, &bloc)
        reset_ballot_marks
        if @contest.voting_method_id == VotingMethod::WINNER_TAKE_ALL.id
          draw_winner config, rect, &bloc
        else
          draw_ranked config, rect, &bloc
        end
      end
      
      def draw_winner(config, rect, &bloc)
        top = rect.top
        
        header(rect)
        
        # CANDIDATES
        candidates_list = @contest.candidates
        candidates_list.sort { |a,b| a.order <=> b.order}.each do |candidate|
          
          if bloc && rect.height < NEXT_COL_BOUNCE
            config.frame_item rect, top
            rect = yield
          end
          
          rect.top -= VPAD * 2
          space, location = config.draw_checkbox rect, candidate.display_name + "\n" + candidate.party.display_name
          ballot_marks << TTV::BallotMark.new(@contest,candidate, @pdf.page_number, location)
        end
        
        @contest.open_seat_count.times do
          if bloc && rect.height < NEXT_COL_BOUNCE
            config.frame_item rect, top
            rect = yield
          end
          rect.top -= VPAD * 2
          left, location = config.draw_checkbox rect, config.bt[:or_write_in]
          ballot_marks << TTV::BallotMark.new(@contest, "Writein", @pdf.page_number, location)
          @pdf.dash 1
          v = 16
          @pdf.stroke_line [rect.left + left, rect.top - v], 
          [rect.right - 6, rect.top - v]
          rect.top -= v
          @pdf.undash
        end
        rect.top -= 6 if @contest.open_seat_count != 0
        config.frame_item rect, top
      end
      
      def draw_ranked(config, rect, &bloc)
        top = rect.top
        
        header(rect)

        # Ordinals: 1st 2nd...
        hpad4 = HPAD2 * 2
        rect.top -= VPAD * 2
        count = @contest.candidates.count
        checkbox_count = [@contest.candidates.count, MAX_RANKED].min
        height = 0
        0.upto(checkbox_count - 1) do |i|
          x = rect.left + HPAD2 + i * (BallotConfig::CHECKBOX_WIDTH + hpad4)
          y = rect.top + VPAD 
          @pdf.bounding_box [x, y], :width => BallotConfig::CHECKBOX_WIDTH do
            @pdf.text(config.et.ordinalize(i + 1), :align => :center)
            height = @pdf.bounds.height
          end
        end
        rect.top -= height;

        # checkboxes

        0.upto(count) do |i|  # candidates
          if bloc && rect.height < NEXT_COL_BOUNCE
            config.frame_item rect, top
            rect = yield
            rect.top -= HPAD2
          end
          0.upto(checkbox_count - 1) do |j|
            x = rect.left + HPAD2 + j * (BallotConfig::CHECKBOX_WIDTH + hpad4)
            y = rect.top
            @pdf.bounding_box [x, y], :width => BallotConfig::CHECKBOX_WIDTH do
              config.stroke_checkbox
              f = @pdf.font "Helvetica", :size => 9
              @pdf.move_down( (BallotConfig::CHECKBOX_HEIGHT - f.ascender) / 2)
              @pdf.fill_color "999999"
              @pdf.text( (j + 1).to_s, :align => :center)
            end
          end
          @pdf.fill_color "000000"
          spacer = HPAD2 + checkbox_count * (BallotConfig::CHECKBOX_WIDTH + hpad4)
          @pdf.font "Helvetica", :size => 10
          @pdf.bounding_box [rect.left + spacer, rect.top], :width => rect.width - spacer do
            if i < count
              @pdf.text config.et.get(@contest.candidates[i], :display_name) + "\n" + config.et.get( @contest.candidates[i].party, :display_name)
            else # writein
              @pdf.text config.bt[:or_write_in]
              @pdf.dash 1
              @pdf.move_down 16
              @pdf.stroke_line [0, 0], [rect.width - spacer - HPAD2, 0]
              @pdf.undash
              @pdf.move_down VPAD
            end            
            rect.top -= [@pdf.bounds.height, BallotConfig::CHECKBOX_HEIGHT].max
          end
          @pdf.move_down VPAD * 2
          rect.top -= VPAD * 2
        end
        config.frame_item rect, top
      end
    end
    
  end
end
