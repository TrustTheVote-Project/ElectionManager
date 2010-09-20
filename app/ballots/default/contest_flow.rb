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
        
        # contest name  and id used in field identifiers
        @cont_name = @contest.display_name.gsub(/\s+/,'_')
        @cont_ident = @contest.ident.gsub(/\s+/,'_')
        
        # active form? 
        @active = @pdf.form?
        
        # used to see if the contest flow will fit
        
        super(@contest, scanner)
      end
      
      def draw_candidate(left,top, width, candidate_name, party_name, options={})
        cb_width = 22
        cb_height = 10
        
        opts = { :top_margin => 0,
          :right_margin => 0,
          :bottom_right => 0,
          :left_margin => HPAD2*2,
          :active => false,
          :select_multiple => false,
          :radio_group => {},
          :id => "cb" }.merge(options)
        
        # draw bounding box at top/left of enclosing rect/bounding box
        @pdf.bounding_box([opts[:left_margin], opts[:top_margin]], :width => cb_width+3) do
          # draw_checkbox draws from lower right of it's bounding box
          # so translate bottom of checkbox to be near bounds.top
          if(opts[:active])
            cb_bottom = @pdf.bounds.top-cb_height 
            if opts[:select_multiple]
              @pdf.draw_checkbox(opts[:id], :at => [0, cb_bottom], :width => cb_width, :height => cb_height)
            else
              # radio_button
              opts[:radio_group][:Kids] << @pdf.draw_radiobutton(opts[:id], :at => [0,cb_bottom], :width => cb_width, :height => cb_height,:selected => false)
            end
          else
            @pdf.rectangle([opts[:left_margin],opts[:top_margin]], cb_width, cb_height)
            @pdf.stroke
          end
        end
        

        # indent  text
        left_text = opts[:left_margin] + cb_width + (HPAD*5) 
        bottom = 0
        # box for wrapping text
        @pdf.bounding_box([left_text, opts[:top_margin]], :width => width - left_text ) do
          @pdf.text(candidate_name)
          @pdf.text(party_name, :style => :normal) if party_name
        end
        
        bottom = @pdf.bounds.top
        contest_bottom = [bottom, cb_height].max 
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

                        @contest.open_seat_count < 2 ? "Vote for not more than (1)" : "Vote for up to #{@contest.open_seat_count}"
                      else
                        "Rank the candidates"
                      end
        
        @pdf.text short_instr, :size => 8, :align => :center, :leading => 1
      end
      

      def header(rect)
        @pdf.bounding_box [rect.left+HPAD, rect.top], :width => rect.width - HPAD2 do
          
          # TODO: make this configurable via ballot style template
          orig_color = @pdf.fill_color
          @pdf.fill_color('DCDCDC')
          @pdf.fill_rectangle([@pdf.bounds.left-HPAD, @pdf.bounds.top], rect.width,  @pdf.height_of(@contest.display_name)+18)
          @pdf.fill_color(orig_color)
          

          @pdf.font "Helvetica", :size => 10, :style => :bold
          @pdf.move_down VPAD
          @pdf.text @contest.display_name, :align => :center, :leading => 1 #header
          @pdf.move_down VPAD
          short_instructions
          rect.top -= @pdf.bounds.height
        end
      end
      
      def draw(config, rect, &bloc)
        reset_ballot_marks
        if @contest.voting_method_id == VotingMethod::WINNER_TAKE_ALL.id
          draw_winner_contest config, rect, &bloc
        else
          draw_ranked config, rect, &bloc
        end
      end
      
      def draw_open_seats(config, rect)

      end
      
      def draw_open_seats_old(config, rect, &bloc)
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
      end

      def draw_all_candidates(config, rect, radio_group, &bloc)
        # CANDIDATES
        candidates_list = @contest.candidates
        candidates_list.sort { |a,b| a.position <=> b.position}.each do |candidate|

          if bloc && rect.height < NEXT_COL_BOUNCE
            config.frame_item rect, top
            rect = yield
          end

          cand_name = candidate.display_name.gsub(/\s+/,'_')
          
          checkbox_id = "#{@cont_ident}+#{cand_name}+#{@cont_name}"
          
          rect.top -= VPAD * 2
          contest_bottom = 0
          
          # need to create a bounding box here in order to get
          # the pdf.text(...) to change it's bounding box???
          @pdf.bounding_box [rect.left, rect.top], :width => rect.width do          
            #contest_text = candidate.display_name + "\n" + candidate.party.display_name
            
            contest_bottom = draw_candidate( 0, contest_bottom, rect.width, candidate.display_name, candidate.party.display_name, :active => @active, :id => checkbox_id, :radio_group => radio_group)
            rect.top -= contest_bottom
          end
          #         TTV::Prawn::Util.show_rect_coordinates(rect)
          #         TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)    
          #         TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)
          #space, location = config.draw_checkbox rect, candidate.display_name + "\n" + candidate.party.display_name
          #ballot_marks << TTV::BallotMark.new(@contest,candidate, @pdf.page_number, location)
        end

        rect.top -= VPAD * 2
        # draw the write-in candiate (radiobutton and text field)
        @pdf.bounding_box [rect.left, rect.top], :width => rect.width do          
          # @contest.open_seat_count.times do |i|

          checkbox_id = "#{@cont_ident}+write_in"
          contest_bottom = draw_candidate( 0, contest_bottom, rect.width, config.bt[:or_write_in],nil, :active => @active, :id => checkbox_id, :radio_group => radio_group, :select_multiple => false) 
          rect.top -= contest_bottom
          rect.top -= VPAD * 2
          @pdf.dash 1
          v = 32
          left = 50
          
          if @active
            textbox_id = "#{@cont_ident}+writein_text"
            @pdf.draw_text_field(textbox_id, :at => [@pdf.bounds.left + left, @pdf.bounds.top - v ], :width => 100, :height => 18)
          end
          @pdf.stroke_line [@pdf.bounds.left + left, @pdf.bounds.top - v],[@pdf.bounds.right - 6, @pdf.bounds.top - v]
          @pdf.undash

          rect.top -= 16
          #end
        end
        
      end
      
      def draw_winner_contest(config, rect, &bloc)
        top = rect.top

        header(rect)
        
        if @active
          # draw a radio group
          @pdf.draw_radio_group(@cont_ident, :at => [ 0,0], :width => 10, :height => 10) do |radio_group|
            draw_all_candidates(config, rect, radio_group)
          end # end radio group
        else
          draw_all_candidates(config, rect, nil)
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
