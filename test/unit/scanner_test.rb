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


=begin
class ScannerTest < ActiveSupport::TestCase
  context "Scanner creation" do
    setup do

      # @election = Election.make
      # @precinct = Precinct.make
      @election = TTV::ImportExport.import(File.new( RAILS_ROOT + "/test/elections/contests_mix.xml"))
      @precinct = @election.district_set.precincts.first
       @template = BallotStyleTemplate.make(:display_name => "test template")
      @c = DefaultBallot::BallotConfig.new( @election, @template)     
#      @c = ::DefaultBallot::BallotConfig.new('default', 'en', @election, @scanner, "missing")
      
      @pdf = create_pdf("Test Scanner")
      @c.setup(@pdf, @precinct)
      
      @scanner = @c.scanner
      
      @renderer = ::AbstractBallot::Renderer.new(@election, @precinct, @c,'')
    end
    
    subject { @scanner}
    
    should "create" do
      assert subject
    end
    
    # align checkbox is just wierd magic/vodoo
    should "align checkbox " do
      HORIZ_PADDING = 6
      top_left, location = subject.align_checkbox(@pdf, [@pdf.bounds.left + HORIZ_PADDING, @pdf.bounds.top])
      # print_bounds @pdf.bounds
    end

    # TODO: doesn't seem to do anything??
    should "render grid" do
      subject.render_grid(@pdf)
      util = TTV::Prawn::Util.new(@pdf)
      assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n", util.page_contents[0]
      
      #puts "object_store = #{util.show_obj_store}"
      
      @pdf.render_file("#{Rails.root}/tmp/scanner_render_grid.pdf")                
    end
    
    # render the four filled in rectangles on the edges of the ballot
    should "render ballot marks" do
      subject.render_ballot_marks(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/scanner_render_ballot_marks.pdf")                
    end
    
    should "render header" do
#      header = DefaultBallot::FlowItem::Header.new("Hey Header",
      #    @scanner)
      header = DefaultBallot::FlowItem::Header.new(@pdf, "Hey Header", nil)
      flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
      
      columns = TTV::Ballot::Columns.new(3, flow_rect)
      # puts "columns = #{columns.inspect}"
      # columns.column_rects.each do |column|
      #         header.draw(@c, column)        
      #       end

      
      @pdf.render_file "/tmp/scan_header.pdf"
    end
    
    should "render ballot_marks" do
      subject.set_checkbox(22,10,:left)
      subject.render_grid @pdf
      subject.render_ballot_marks @pdf
      
      @pdf.render_file "/tmp/scanner_render_grid.pdf"
    end

    #     should "render it all " do
    #       File.open "renderer.pdf", 'w' do |f|
    #         f.write(@renderer.render)
    #       end
    #     end
  end
end
=end
