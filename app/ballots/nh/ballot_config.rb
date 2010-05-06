#
# NhBallot implements a columnar office format
#
require 'ttv/abstract_ballot'
require 'ballots/default/ballot_config'
require 'prawn'

module NhBallot
  include AbstractBallot

  class FlowItem 
    TINY_FONT = 7
    SMALL_FONT = 9
    BIG_FONT = 11

    class NHContest < DefaultBallot::FlowItem::Contest
      def initialize(item, scanner)
        super
      end

      # returns height
      def draw_column(config, rect, candidates)
       
        return 0 if candidates.length == 0
        height = 0
        
        draw_party = !(candidates[0].party.idToXml == 'democrat' || candidates[0].party.idToXml == 'republican')
        config.pdf.bounding_box [rect.left + HPAD, rect.top], :width => rect.width - HPAD2 do
          candidates.each_index do |i|
            candidate = candidates[i]
            config.pdf.move_down VPAD2
          
            # Render name of candidate
            config.pdf.bounding_box [0, 0], :width => 80 do
              config.pdf.font "Helvetica", :size => BIG_FONT
              name = config.et.get(candidate, :display_name)
              name = name.sub(" and ", "\n") # hack to split joint names to two lines, wont work i10n
              name = name 
              config.pdf.move_down 10
              config.pdf.text name, :align => :left
              config.pdf.move_down 10
            end
            #OVAL BOX TO THE RIGHT OF THE CANDIDATE NAME
            config.pdf.bounding_box [75,20], :width => 20 do
               config.stroke_checkbox
             end
             config.pdf.move_down 12
             
             # PARTY NAME FOR CANDIDATE
             if draw_party
               config.pdf.font "Helvetica", :size => SMALL_FONT
               config.pdf.text config.et.get(candidate.party, :display_name), :align => :left
             end
     
            config.pdf.line [0, 0], [rect.width - HPAD2, 0] unless (i == candidates.length - 1)
          end
          height = config.pdf.bounds.height
        end
        return height
      end

      def draw_writein_column(config, rect)
        height = 0
        config.pdf.font "Helvetica", :size => TINY_FONT
        config.pdf.bounding_box [rect.left, rect.top], :width => rect.width do
          @item.open_seat_count.times do 
            config.pdf.move_down 30
            config.pdf.text config.et.get(@item, :display_name), :align => :center
            config.pdf.line [0, 0], [rect.width, 0]
            config.pdf.move_down VPAD
          end
          height = config.pdf.bounds.height
        end
        height
      end

      def draw(config, rect, &bloc)
        reset_ballot_marks
        top = rect.top
        # draw candidates first, to figure out max height
        democrats = []
        republicans = []
        others = []
        @item.candidates.each do |candidate|
          case 
          when candidate.party.idToXml == 'democrat' then democrats.push candidate
          when candidate.party.idToXml == 'republican' then republicans.push candidate
          else others.push candidate
          end
        end
        # draw candidates
        r = rect.clone
        r.left, r.right = rect.left + config.col_width, rect.left + config.col_width * 2
        height = draw_column(config, r, democrats)
        r.left, r.right = rect.left + config.col_width * 2, rect.left + config.col_width * 3
        height = [height, draw_column(config, r, others)].max
        r.left, r.right = rect.left + config.col_width * 3, rect.left + config.col_width * 4
        height = [height, draw_column(config, r, republicans)].max
        r.left, r.right = rect.left + config.col_width * 4, rect.left + config.col_width * 5
        height = [height, draw_writein_column(config, r)].max

        # OFFICES
          config.pdf.bounding_box [rect.left+HPAD, rect.top], :width => config.col_width - HPAD2 do
          config.pdf.move_down VPAD2
          config.pdf.font "Helvetica", :size => TINY_FONT
          config.pdf.text config.bt[:For]
          config.pdf.font "Helvetica", :size => BIG_FONT
          config.pdf.text config.et.get(@item, :display_name), :align => :center
          config.pdf.move_down VPAD
          config.pdf.font "Helvetica", :size => TINY_FONT
          config.pdf.text config.short_instructions(@item), :align => :center
          height = [height, config.pdf.bounds.height].max
        end
        
        # draw vertical bars
        config.pdf.bounding_box [rect.left, rect.top], :width => rect.width, :height =>height do
          4.times do |i|
            config.pdf.line [config.col_width * (i+1), 0], [config.col_width * (i+1), height]
          end
        end
        rect.top -= height;
        #puts "height was #{height} for item #{@item}"
        config.pdf.stroke_line [rect.left, rect.top], [rect.right, rect.top]
        
        
      end
    end # class NHContest
    
  end # class FlowItem

  class BallotConfig < DefaultBallot::BallotConfig

    attr_accessor :col_width

    def initialize(style, lang, election, scanner, instruction_text_url)
      @instruction_text = instruction_text_url
      @state_seal = state_seal
      @state_signature = state_signature
      @checkbox_orientation = :right
      @columns = 1
      super
    end

    def col_loc(i)
      @col_left + i * @col_width
    end

    def render_header(flow_rect)
      @pdf.font "Helvetica", :size => 14,  :style => :bold
      @col_headers = ["OFFICES", "DEMOCRATIC CANDIDATES", "OTHER CANDIDATES", "REPUBLICAN CANDIDATES", "WRITE-IN\nCANDIDATES"]
      @col_width = flow_rect.width / @col_headers.length
      @col_left = flow_rect.left
      @header_height = 40
      @col_headers.length.times do |i|            
        #640 BELOW IS THE TOP LOCATION OF THE COLUMN HEADERS, NEED TO PARAMATIZE THIS
        @pdf.bounding_box [col_loc(i), 640], :width => @col_width, :height => @header_height do
          @pdf.fill_color '000000'
          @pdf.stroke_color 'FFFFFF'
          @pdf.rectangle [0, 0], @col_width, -@header_height
          @pdf.line([@col_width, 0], [@col_width, @header_height]) 
          @pdf.fill_and_stroke
          @pdf.fill_color 'FFFFFF'
          @pdf.text_box @col_headers[i], :at => [0, @header_height - 6], :align => :center
        end
      end
      flow_rect.top = 600  #TOP LOCATION OF COLUMNS 
      @pdf.stroke_color "000000"
      @pdf.fill_color '000000'
      @pdf.stroke_line [flow_rect.left, flow_rect.top], [flow_rect.right, flow_rect.top]
    end

    def render_column_instructions(columns, page)
      
    end

    def stroke_checkbox(pt = [0,0])
      @pdf.line_width 1.5
      @pdf.fill_color "FFFFFF"
      @pdf.stroke_color "000000"
      @pdf.ellipse_at [pt[0]+ CHECKBOX_WIDTH / 2, pt[1] - CHECKBOX_HEIGHT / 2 ] , CHECKBOX_WIDTH/ 2, CHECKBOX_HEIGHT / 2
      @pdf.fill_and_stroke
      @pdf.fill_color "000000"
    end
    
    
    def page_complete(pagenum, last_page)
      #unless last_page
        #BALLOT TITLE ON TOP LEFT BALLOT
        @pdf.bounding_box [ 20, @pdf.bounds.height], :width => 150 do
             @pdf.font "Helvetica", :size => 10, :style => :bold
             @pdf.text ballot_translation[:Title_Text], :align => :center
             state_signature = "#{RAILS_ROOT}/public/images/state_graphics/#{@state_signature}"
             @pdf.image state_signature, :at => [20,@pdf.bounds.height - 55], :width => 100, :height => 30
           @pdf.bounding_box [ 135 , @pdf.bounds.height - 45], :width => 150 do
            state_seal = "#{RAILS_ROOT}/public/images/state_graphics/#{@state_seal}"
            @pdf.image state_seal, :at => [0,@pdf.bounds.height + 40], :width => 80, :height => 80
           end
         end
        #INSTRUCTIONS ON TOP OF BALLOT
        @pdf.bounding_box [ 240 , @pdf.bounds.height], :width => 300 do
          @pdf.font "Helvetica", :size => 14, :style => :bold
          @pdf.text ballot_translation[:Instruction_To_Voters], :align => :center
          @pdf.font "Helvetica", :size => 8
          #@pdf.text ballot_translation[:Instruction_Text1], :align => :left
          #@pdf.text ballot_translation[:Instruction_Text2], :align => :left
          @pdf.text @instruction_text
        end
        @pdf.bounding_box [ 0 , @pleaseVoteHeight ], :width => @pdf.bounds.width do
          @pdf.move_down 10
          @pdf.text bt[:Vote_Both_Sides], :align => :center
        end
      #end
    end
    

    def create_flow_item(item)
      case
      when item.is_a?(Contest) then FlowItem::NHContest.new(item, @scanner)
      when item.is_a?(Question) then super
      when item.is_a?(String) then super
      when item.is_a?(Array) then item[1] # hack, gets rid of district name
      else raise "Unknown flow item"
      end
    end

  end
end
