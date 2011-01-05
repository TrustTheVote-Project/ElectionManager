# OSDV Election Manager - Unit Test for BallotConfig for DC
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
require Rails.root.join('app','ballots','dc', 'ballot_config')

class BallotConfigDCTest < ActiveSupport::TestCase
  context "initialize " do
    setup do
      
      @e1 = Election.make(:display_name => "Election 1")
      @p1 = Precinct.make(:display_name => "Precint 1")
      
      @template = BallotStyleTemplate.make(:display_name => "test template")
      
      # @template.page = ballot_page
      # @template.frame = ballot_frame
      # @template.contents = ballot_contents
      @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/test_stylesheet.yml")
      #puts "TGD: @template.contents = #{@template.contents.inspect}"
      #puts "TGD: bbb @template.contents['margin']['header'] = #{@template.contents['header']['margin'].inspect}"
      
      @c = @ballot_config = DcBallot::BallotConfig.new( @e1, @template)
      @pdf = create_document(@template)      
#      @pdf = ::Prawn::Document.new( :page_layout => @template.page['layout']# , 
#                                    :page_size => @template.page['size'],
#                                     :left_margin => @template.frame['margin']['left'],
#                                     :right_margin => @template.frame['margin']['right'],
#                                     :top_margin =>  @template.frame['margin']['top'],
#                                     :bottom_margin =>  @template.frame[:margin][:bottom],
#                                    :info => { :Creator => "TrustTheVote",
#                                    :Title => "#{@e1.display_name}  #{@p1.display_name} ballot"} )
      
      # @pdf = create_pdf("Test Default Ballot")
      
      # outline page border in green
      # @pdf.stroke_color "#FF0000"
      # @pdf.stroke_bounds
      # @pdf.stroke_color "#000000"

      @ballot_config.setup(@pdf, @p1)
      
    end # end setup
    
    should "create a ballot config " do
      assert @ballot_config
    end
    
    should "render a frame with a solid border" do
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
      @ballot_config.render_frame flow_rect
      util = TTV::Prawn::Util.new(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_frame_solid_border.pdf")          
    end
    
    should "render a frame around wit a dashed border" do
      @template.frame['border']['style'] = :dashed
      
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
      @ballot_config.render_frame flow_rect
      util = TTV::Prawn::Util.new(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_frame_dashed_border.pdf")          
    end
    
    
    should "render a frame around without a border" do
      @template.frame['border']['style'] = :none
      
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
      @ballot_config.render_frame flow_rect
      util = TTV::Prawn::Util.new(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_frame_no_border.pdf")          
    end
    
    should "render a contents for this page" do
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
      @ballot_config.render_frame flow_rect
      @ballot_config.render_contents flow_rect
      @pdf.render_file("#{Rails.root}/tmp/ballot_render_dc_contents.pdf")          
    end

    
    def ballot_page
      # see Prawn::Document::PageGeometry
      # LETTER => width = 612.00 pts, heigth= 792.00 pts
      #  612/72, 792/72  where 72 pts/in
      # width = 8.5 in, heigth= 11 in
      page = {}
      page[:size] = "LETTER" 
      page[:layout] = :portrait # :portrait or :landscape
      page[:background] = '#000000'
      # page[:margin] = { :top => 30, :right => 18, :bottom => 30, :left => 18}
      
      page[:margin] = { :top => 20, :right => 20, :bottom => 20, :left => 20}

      page
    end
    
    
  end # end initialize context
  

end
