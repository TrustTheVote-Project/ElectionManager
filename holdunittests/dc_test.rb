# OSDV Election Manager - Unit Test
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require File.dirname(__FILE__) + '/../test_helper'

class RendererTest < ActiveSupport::TestCase
  
  context "DCBallot::Renderer " do
    
    setup do
      fed_district = District.make(:display_name => "Federal")
      
      # create a jurisdiction with  2 districts 
      dc_jurisdiction  = DistrictSet.create!(:display_name => "District of Columbia")
      dc_jurisdiction.districts << fed_district
      dc_jurisdiction.jur_districts << fed_district
      dc_jurisdiction.save!

      # create a precint within 4 Districts
      p1 = Precinct.create!(:display_name => "PRECINCT 1 01")
      p1.jurisdiction = dc_jurisdiction
      @prec_split1 = PrecinctSplit.make(:display_name => "Precinct Split 1", :precinct => p1, :district_set => dc_jurisdiction)
      p1.precinct_splits << @prec_split1
      p1.save
      
      # make an election for this jurisdiction
      @election = Election.create!(:display_name => "MAYORAL PRIMARY ELECTION", :district_set => dc_jurisdiction)
      @election.start_date = DateTime.new(2009, 9, 14)
      
      dem_party = Party.make(:democrat)
      rep_party = Party.make(:republican)
      
      contest1 = Contest.make(:display_name => "DELEGATE TO THE U.S. HOUSE OF REPRESENTATIVES",
                           :voting_method => VotingMethod::WINNER_TAKE_ALL,
                           :district => fed_district,
                           :election => @election,
                           :position => 1, :ident => 'ident-1')

      Candidate.make(:party => dem_party, :display_name => "Missy Reilly Smith", :contest => contest1, :ident => 'ident-1')
      
      mayor_contest = Contest.make(:display_name => "MAYOR OF THE DISTRICT OF COLUMBIA",
                           :voting_method => VotingMethod::WINNER_TAKE_ALL,
                           :district => fed_district,
                           :election => @election,
                           :position => 1, :ident => 'ident-2' )

      Candidate.make(:party => rep_party, :display_name => "Robert Vaughn", :contest => mayor_contest, :ident => 'ident-2')
      Candidate.make(:party => dem_party, :display_name => "Ian Trainor", :contest => mayor_contest, :ident => 'ident-3')
      
      chair_contest = Contest.make(:display_name => "CHAIRMAN OF THE COUNCIL",
                           :voting_method => VotingMethod::WINNER_TAKE_ALL,
                           :district => fed_district,
                           :election => @election,
                           :position => 2, :ident => 'ident-3')

      Candidate.make(:party => rep_party, :display_name => "Marcella Farrell", :contest => chair_contest, :ident => 'ident-4')
      Candidate.make(:party => dem_party, :display_name => "Darby Rush", :contest => chair_contest, :ident => 'ident-5')
      
      atlarge_contest = Contest.make(:display_name => "AT-LARGE MEMBER OF THE COUNCIL",
                           :voting_method => VotingMethod::WINNER_TAKE_ALL,
                           :district => fed_district,
                           :election => @election,
                           :position => 3, :ident => 'ident-4')

      Candidate.make(:party => rep_party, :display_name => "Catherine Calnan", :contest => atlarge_contest, :ident => 'ident-6')
      Candidate.make(:party => dem_party, :display_name => "Sybina Cull", :contest => atlarge_contest, :ident => 'ident-7')
      
      ward_contest = Contest.make(:display_name => "WARD COUNCIL",
                           :voting_method => VotingMethod::WINNER_TAKE_ALL,
                           :district => fed_district,
                           :election => @election,
                           :position => 4, :ident => 'ident-5')

      Candidate.make(:party => rep_party, :display_name => "Mike Donelan", :contest => ward_contest, :ident => 'ident-8')
      Candidate.make(:party => dem_party, :display_name => "Cassie McDonald", :contest => ward_contest, :ident => 'ident-9')

      # @template = BallotStyleTemplate.make(:display_name => "test template")
      @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => true)
      @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/test_stylesheet.yml")
      @election.ballot_style_template_id = @template.id
      
      @ballot_config = DcBallot::BallotConfig.new( @election, @template)

      @pdf = create_document(@template)
      @ballot_config.setup( @pdf,  p1)

      
      @renderer = AbstractBallot::Renderer.new(@election, @prec_split1, @ballot_config, nil)
      @renderer.instance_variable_set(:@pdf, @pdf)
    end
    
    should "render" do
      # @renderer.render
      @renderer.instance_variable_set(:@flow_items,::DefaultBallot::FlowItem.init_flow_items(@pdf, @election, @prec_split1, @template))
      @renderer.render_everything
      #pdf = @renderer.instance_variable_get(:@pdf)
      @pdf.render_file("#{Rails.root}/tmp/DCBallot.pdf")

    end
  end
      
  def contents
    
    contents = {
      :border => {:width => 2, :color => '#00000F', :style => :dashed},
      
      #:width => 1.0, # % width of ballot contents box
      #:height => 0.15, # % height of ballot contents box

      :header =>{
        :width => 498,
        :height => 154,
        :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
        :border => {:width => 0, :color => '00000', :style => :solid},
        :text => "Header Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#0000FF',
        :graphics => nil
      },
      
      :footer =>{
        :width => 1.0, # % width of ballot contents box
        # :height => 0.15, # % height of ballot contents box
        :height => 0.15, # % height of ballot contents box
        :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
        :border => {:width => 0, :color => 'FF0000', :style => :solid},
        :text => "Footer Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#00FF00',
        :graphics => nil
      },
      
      :body =>{
        :width => 1.0, # % width of ballot contents box
        :height => 0.7, # % height of ballot contents box
        :margin => {:top => 0, :right => 0, :bottom => 0, :left => 0},
        :border => {:width => 0, :color => '000000', :style => :solid},
        :text => "Body Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#FF0000',
        :graphics => nil
      }
      
    }

    # header, minus instructions
    contents[:header][:graphics] = <<-'HEADER'
      
      # draw yellow background rectangle
      orig_color = @pdf.fill_color
      @pdf.fill_color('F0E68C')
      rect_x = 36
      rect_y= @pdf.bounds.top - 14
      rect_width = 430
      rect_height = 53
      @pdf.fill_rectangle([rect_x, rect_y], rect_width, rect_height)
      @pdf.fill_color(orig_color)

      # Election Date is used in header
      edate = Date.parse("#{@election.start_date}").strftime("%A, %B %d, %Y" )
      
      @pdf.move_down 14
      @pdf.text "OFFICIAL REPUBLICAN BALLOT\n#{@election.display_name}", :align => :center, :style => :bold
      @pdf.text "#{@election.district_set.display_name}\n#{edate}", :align => :center

      
      # TODO: Need to add more fonts and register them.
      # puts @pdf.font_families.inspect
      # @pdf.font_families.update({ "Helvetica" => { :bold_narrow => "Helvetica-Narrow-Bold"}})
      
      # instructions
      @pdf.bounding_box [0, @pdf.bounds.top - 82], :width => @pdf.bounds.width, :height => @pdf.bounds.height - 82 do
        
        @pdf.stroke_bounds
        
        @pdf.move_down 3
        @pdf.font "Helvetica", :style => :bold, :size => 10 do
          @pdf.text "INSTRUCTIONS TO VOTER", :align => :center
        end
        
        @pdf.move_down 5
        instr_text = "1. TO VOTE YOU MUST DARKEN THE OVAL TO THE LEFT OF YOUR CHOICE COMPLETELY. An oval darkened to the left of the name of any candidate indicates a vote for that candidate.\n2. Use only a pencil or blue or black medium ball point pen.\n3. If you make a mistake DO NOT ERASE. Ask for a new ballot.\n4. For a Write-in candidate, write the name of the person on the line and darken the oval."
        y = @pdf.bounds.top - @pdf.height_of("TEXT")
        @pdf.text instr_text, :size => 8
      end
      
    HEADER
    
    contents
  end
      def page
        # see Prawn::Document::PageGeometry
        # LETTER => width = 612.00 pts, heigth= 792.00 pts
        #  612/72, 792/72  where 72 pts/in
        # width = 8.5 in, heigth= 11 in
        page = {}
        #        page[:size] = "LETTER"
        page[:size] = [612,1152]
        page[:layout] = :portrait # :portrait or :landscape
        page[:background] = '#000000'
        page[:margin] = { :top => 0, :right => 0, :bottom => 0, :left => 0}
        page
      end
    
  def frame
    # MARGIN
    # surrounds the border, size of whitespace surrounding the frame
    # inside the page margin.
    frame = { }
    frame[:margin] = {:top => 0, :right => 0, :bottom => 0, :left => 0}
    
    # BORDER
    # surrounds the padding
    # width, color, style(dotted, dashed, solid)
    # {:width => 2, :color => '#FF0000', :style => :solid}
    frame[:border] = {:width => 0 }# , :color => '#00FF00', :style => :solid}

    frame[:content] = {
      :top => { :width => 50, :text => "Sample Ballot", :rotate => 90, :graphics => nil },
      :right => { :width => 47,:text => " tom D was here", :rotate => 90, :graphics => nil },
      :bottom => { :width => 190,:text => "Sample Ballot", :rotate => 90, :graphics => nil },
      :left => { :width => 67,:text => "    132301113              Sample Ballot", :rotate => 90, :graphics => nil }
    }
    
    frame[:content][:top][:graphics] = <<-'CONTENT_TOP'


      #text = @frame[:content][:top][:text]
      text = @precinct.display_name
      middle_x = @pdf.bounds.right/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.top - @frame[:content][:top][:width]/2 + @pdf.height_of(text)/2
      @pdf.font("Times-Roman", :size => 18, :style => :bold) do
        @pdf.draw_text text, :at => [middle_x, middle_y]
      end
    CONTENT_TOP
    
    frame[:content][:bottom][:graphics] = <<-'CONTENT_BOTTOM' 

      text = @precinct.display_name
      middle_x = @pdf.bounds.right/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.bottom + @frame[:content][:bottom][:width]/2 - @pdf.height_of(text)/2
      @pdf.font("Times-Roman", :size => 18, :style => :bold) do
        @pdf.draw_text text, :at => [middle_x, middle_y]
      end
    CONTENT_BOTTOM

    frame
  end

end 
