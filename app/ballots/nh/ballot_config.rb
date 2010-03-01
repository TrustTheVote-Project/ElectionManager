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
            if draw_party
              config.pdf.font "Helvetica", :size => SMALL_FONT
              config.pdf.text config.et.get(candidate.party, :display_name), :align => :center
            end
          
# Render name of candidate
            config.pdf.bounding_box [0, 0], :width => 80 do
              config.pdf.font "Helvetica", :size => BIG_FONT
              name = config.et.get(candidate, :display_name)
              name = name.sub(" and ", "\n") # hack to split joint names to two lines, wont work i10n
              config.pdf.text name, :align => :right
            end
 #           config.pdf.bounding_box [0,81], :width => 20 do
  #            config.stroke_checkbox
   #         end
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

        # draw title
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
        puts "height was #{height} for item #{@item}"
        config.pdf.stroke_line [rect.left, rect.top], [rect.right, rect.top]
      end
    end # class NHContest
    
  end # class FlowItem

  class BallotConfig < DefaultBallot::BallotConfig

    attr_accessor :col_width

    def initialize(style, lang, election, scanner)
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
        @pdf.bounding_box [col_loc(i), flow_rect.top], :width => @col_width, :height => @header_height do
          @pdf.fill_color '000000'
          @pdf.stroke_color 'FFFFFF'
          @pdf.rectangle [0, 0], @col_width, -@header_height
          @pdf.line([@col_width, 0], [@col_width, @header_height]) 
          @pdf.fill_and_stroke
          @pdf.fill_color 'FFFFFF'
          @pdf.text_box @col_headers[i], :at => [0, @header_height - 6], :align => :center
        end
      end
      flow_rect.top -= @header_height
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
