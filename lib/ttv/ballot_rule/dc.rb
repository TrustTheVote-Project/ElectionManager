module ::TTV
  module BallotRule
    
    # NOTE: Don't forget to add this class to the ballot_rules.rb
    # initializer!!
    class DC < BallotRule::Base
      class << self
        def district_order
          @district_order ||= { "SMD" => 0, "COND" => 1,  "WARD" => 2,"CITYWI" => 3, "JOHN" => 4}
        end
      end

      # testing in console:
      # juris.jur_districts.sort(&bst.district_ordering).map(&:district_type).map(&:title)
      # where juris = jurisdiction and bst = ballot style template
      
      # district ordering shb:
      # 1) Federal (JOHN), 2) District of Columbia (CITYWI),
      # 3) Ward (WARD), 4) Congressional District (COND),
      # 5) SMD (SMD)
      # where: JOHN, CITYWI, WARD, COND AND SMD are the district types
      # in the import file
      def district_ordering
        return lambda do |d1, d2|
          # from the story, 5280202
          #%w{ FEDERAL COLUMBIA WARD CONGRESSIONAL SMD}.each_index do |i,ident|
          #  District.all.map{ |d| d.position = i; d.save! if d.ident =~ /ident/ }.compact 
          #end

          # where the district.district_type.titles
          # ["JOHN", "WARD", "CITYWI", "COND", "SMD"]
          # map to district.ident with substrings: 
          # ["FEDERAL", "WARD", "COLUMBIA", "CONGRESSIONAL", "SMD"]
          self.class.district_order[d2.district_type.title] <=> self.class.district_order[d1.district_type.title] 
        end
      end # end district_ordering

      # TODO: move this rendering code out of ballot rules.
      # This should be:
      # - replaced by PDF rich text in the ballot style files
      # OR
      # - rendered in rails views that generate pdf, see prawn_to gem

      # draw the text at that top of the ballot
      def frame_content_top(ballot_config)
        pdf = ballot_config.pdf
        frame = ballot_config.frame
        precinct = ballot_config.precinct
        
        text = "#{precinct.precinct.display_name} - #{precinct.display_name.gsub(/ds-\d+-/, '')}"
        # center text at the top of the ballot
        middle_x = pdf.bounds.right/2 - pdf.width_of(text)/2 ;
        middle_y = pdf.bounds.top - frame[:content][:top][:width]/2 + pdf.height_of(text)/2
        # draw text
        pdf.draw_text(text, :at => [middle_x, middle_y-10], :style => :bold)
      end

      # draw the text at that bottom of the ballot
      def frame_content_bottom(ballot_config)
        pdf = ballot_config.pdf
        frame = ballot_config.frame
        precinct = ballot_config.precinct
        
        text = "#{precinct.precinct.display_name} - #{precinct.display_name.gsub(/ds-\d+-/, '')}";
        # center text        
        middle_x = pdf.bounds.right/2 - pdf.width_of(text)/2;
        middle_y = pdf.bounds.bottom + frame[:content][:bottom][:width]/2 - pdf.height_of(text)/2;
        #draw text
        pdf.draw_text(text, :at => [middle_x, middle_y], :style => :bold);
      end
      
      # draw the text in the ballot header      
      def contents_header(ballot_config)
        pdf = ballot_config.pdf
        frame = ballot_config.frame
        precinct = ballot_config.precinct
        election = ballot_config.election
        template = ballot_config.template
        
        # draw yellow background for the header
        orig_color = pdf.fill_color;
        pdf.fill_color('F0E68C');
        rect_x = 36;
        rect_y= pdf.bounds.top - 10;
        rect_width = 430;
        rect_height = 57;
        pdf.fill_rectangle([rect_x, rect_y], rect_width, rect_height);
        # restore color
        pdf.fill_color(orig_color);
        
        # draw header 
        edate = Date.parse("#{election.start_date}").strftime("%B %d, %Y")
        pdf.move_down 14
        pdf.text("#{template.ballot_title}\n#{election.display_name}", :align => :center, :style => :bold )
        pdf.text("#{precinct.precinct.display_name}\n#{edate}", :align => :center );

        # TODO: move instruction rendering out of header rendering
        pdf.stroke_line(0, pdf.bounds.top - 82, pdf.bounds.width, pdf.bounds.top - 82);
        pdf.bounding_box([5, pdf.bounds.top - 82], :width => pdf.bounds.width-10, :height => pdf.bounds.height - 82) do;
          pdf.move_down(3);
          pdf.font("Helvetica", :style => :bold, :size => 10) do;
            pdf.text("INSTRUCTIONS TO VOTER", :align => :center);
          end;
          instr_text = "1. TO VOTE YOU MUST DARKEN THE OVAL TO THE LEFT OF YOUR CHOICE COMPLETELY. An oval darkened to the left of the name of any candidate indicates a vote for that candidate.\n2. For online completion of ballot, click on oval next to desired choices. For printed paper ballot, use only a number 2 pencil or blue or black ink, and darken the oval next to your desired choice.\n3. If you make a mistake DO NOT ERASE. Ask for a new ballot.\n4. For a Write-in candidate, write the name of the person on the line and darken the oval.";
          y = pdf.bounds.top - pdf.height_of("TEXT");
          pdf.text(instr_text, :size => 8);
        end
        
      end
      
      # TODO: Refactor so that we don't depend on flow_items
      def process_flow_items(flow_items)
#         flow_items.each do  |item|
#            puts "TGD1: flow_item = #{item}"
#            puts "TGD1: flow_item = #{item.class.name.inspect}"
#         end
        questions = []
        contests = []
        flow_items.each do |item|
         if item.class.name == "DefaultBallot::FlowItem::Contest"
           contests << item
         elsif item.class.name == "DefaultBallot::FlowItem::Question"
           questions << item
         else
           raise Exception, "Unknown FlowItem class #{item.class.name}"
         end
        end
        flow_items = contests + questions
        # re-orders contests NOT GOOD
#         order = { "DefaultBallot::FlowItem::Contest" => 0, "DefaultBallot::FlowItem::Question" => 1}
#         flow_items.sort! do |item1, item2|
#           order[item1.class.name] <=> order[item2.class.name]
#         end
#          flow_items.each do  |item|
#            puts "TGD2: flow_item = #{item}"
#            puts "TGD2: flow_item = #{item.class.name.inspect}"
#          end
        flow_items
      end
      
    end # end DC class
    
  end # end BallotRule module
end # end TTV module
