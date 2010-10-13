module ::TTV
  module BallotRule
    
    # NOTE: Don't forget to add this class to the ballot_rules.rb
    # initializer!!
    class VA < BallotRule::Base

      # class singleton methods
      class << self

        # create the party ordering used in the candidate ordering
        # rule below
        def party_order
          # create it once for this class
          @party_order ||=  {Party::INDEPENDENT => 0, Party::LIBERTARIAN => 1, Party::INDEPENDENTGREEN => 2, Party::DEMOCRATIC => 3, Party::DEMOCRAT => 3, Party::REPUBLICAN => 4}
        end
        
      end # end class singleton methods
      
      def initialize(election=nil, precinct_split=nil)
        # TODO: may want to remove as thes are not currently used 
        @election = election
        @precinct_split = precinct_split
      end
      
      def contest_include_party(contest)
        raise ArgumentError, "#{self.class.name}#contest_include_party: argument must be a Contest" unless contest.is_a?(Contest)
        
        contest.district.district_type.title.downcase == "congressional"
      end # end contest_include_party
      
      def candidate_ordering
        
        return lambda do |c1, c2|
          # puts "TGD: c1 = #{c1.display_name}"
          # puts "TGD: c1.party = #{c1.party.display_name}"
          # puts "TGD: c2 = #{c2.display_name}"
          # puts "TGD: c2.party = #{c2.party.display_name}"

          # puts "part_order = #{self.class.party_order.inspect}"
          if c1.party == c2.party
            c1.display_name <=> c2.display_name
          else
            # set the default to indy if candidate doesn't have a party
            c1.party = Party::INDEPENDENT unless c1.party
            c2.party = Party::INDEPENDENT unless c2.party
            # order candidates according to their party
            self.class.party_order[c2.party] <=> self.class.party_order[c1.party]
          end
        end
      end # end candidate_ordering

      def frame_content_top(ballot_config)
        pdf = ballot_config.pdf
        frame = ballot_config.frame
        
        pdf.move_down(20);
        text = "Automated Write-In Absentee Ballot Authorized by Virginia State Board of Elections";
        text << "\n1100  Bank St., Richmond, VA 23219";
        middle_x = pdf.bounds.right/2 - pdf.width_of(text)/2 ;
        middle_y = pdf.bounds.top - frame[:content][:top][:width]/2 + pdf.height_of(text)/2 ;
        pdf.text(text, :style => :bold, :align => :center, :size => 8);
      end
      
      def frame_content_bottom(ballot_config)
        pdf = ballot_config.pdf
        precinct = ballot_config.precinct
        frame = ballot_config.frame
        text = "#{precinct.precinct.display_name} - #{precinct.display_name.gsub(/ds-\d+-/, '')}"
        middle_x = pdf.bounds.right/2 - pdf.width_of(text)/2;
        middle_y = pdf.bounds.bottom + frame[:content][:bottom][:width]/2 - pdf.height_of(text)/2;
        pdf.draw_text(text, :at => [middle_x, middle_y+10], :size => 8, :style => :bold);
      end

      def contents_header(ballot_config)
        pdf = ballot_config.pdf
        precinct = ballot_config.precinct
        template = ballot_config.template
        orig_color = pdf.fill_color;
        pdf.fill_color('F0E68C');
        rect_x = 36;
        rect_y= pdf.bounds.top - 10;
        rect_width = 430;
        rect_height = 57;
        pdf.fill_rectangle([rect_x, rect_y], rect_width, rect_height);
        pdf.fill_color(orig_color);
        edate = 'November 2, 2010';
        pdf.move_down 14 ;
        pdf.text("#{template.ballot_title}", :align => :center, :style => :bold );
        pdf.text("General Election", :align => :center, :style => :bold );
        pdf.text("#{precinct.precinct.display_name}\n#{edate}", :align => :center );
        
        # TODO: move instruction rendering out of header rendering
        # here we render instructions within the header
        pdf.stroke_line(0, pdf.bounds.top - 82, pdf.bounds.width, pdf.bounds.top - 82);
        pdf.bounding_box([5, pdf.bounds.top - 82], :width => pdf.bounds.width-10, :height => pdf.bounds.height - 82) do;
          pdf.move_down(3);
          pdf.font("Helvetica", :style => :bold, :size => 10) do;
            pdf.text("INSTRUCTIONS TO VOTER", :align => :center);
          end;
          
          pdf.move_down(5);
          instr_text = "1. TO VOTE YOU MUST DARKEN THE OVAL TO THE LEFT OF YOUR CHOICE COMPLETELY. An oval darkened to the left of the name of any candidate indicates a vote for that candidate.\n2. Use only a pencil or blue or black medium ball point pen.\n3. If you make a mistake DO NOT ERASE. Ask for a new ballot.\n4. For a Write-in candidate, write the name of the person on the line and darken the oval.";
          y = pdf.bounds.top - pdf.height_of("TEXT");
          pdf.text(instr_text, :size => 8);
        end # end bounding box
      end
      
      def contents_body(ballot_config)
      end
      def contents_footer(ballot_config)
      end
      
    end # end VA class
  end # end BallotRule module
end # end TTV module
