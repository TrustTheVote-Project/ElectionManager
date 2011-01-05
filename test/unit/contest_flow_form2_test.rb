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

class ContestFlowFormTest < ActiveSupport::TestCase
  
  context "DefaultBallot::FlowItem::Contest" do
    setup do
      # create a ballot config without a pdf form
      # create_ballot_config(false)
      
      # create a ballot config for pdf form
      create_ballot_config(true)
      
      # create a flow rect/frame to enclose all the columns
      flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)
        
      # draw aqua outline/stroke around the flow rectangle
      TTV::Prawn::Util.stroke_rect(@pdf, flow_rect, "#ffffff")
        
      # create 3 columns of equal width within the frame
      @columns = TTV::Ballot::Columns.new(3, flow_rect)
        
      # get the first, leftmost, column
      @current_column = @columns.next
        
      # draw red outline/stroke around the columns that have content
      TTV::Prawn::Util.stroke_rect(@pdf, @current_column)
    end
    context "that overflows" do
      setup do
        # create 5 contests 
        @flow_items = []
        %w{  Contest1 Contest2 Contest3 Contest4 Contest5 }.each do |name|
          contest = create_contest(name, VotingMethod::WINNER_TAKE_ALL, @district, @election )
          @flow_items <<       @contest_flow = DefaultBallot::FlowItem::Contest.new(@pdf, contest, @scanner)      
        end

      end
      
      should "draw in two columns" do
        
        @flow_items.each do |contest_flow|
          
          fits = contest_flow.fits(@ballot_config, @current_column)
          @current_column = @columns.next unless fits

          contest_flow.draw(@ballot_config, @current_column)
        end
        
        #reader = TTV::Prawn::Reader.new(@pdf)
        
        # make sure we've bumped up the current column 
        assert_not_equal @columns.first, @current_column

        # make sure the object store annotation ref has the same set
        # of references as the page annotation ref!!
        #assert_equal @pdf.annotations_in_object_store, @pdf.annotations

        @pdf.render_file("#{Rails.root}/tmp/contest_flow_form2.pdf")

      end
    end
    
  end
end
