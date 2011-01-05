# OSDV Election Manager - Unit Test for BallotConfigForm
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
class BallotConfigFormTest < ActiveSupport::TestCase
  setup_jurisdictions do  
    
    context "Default::BallotConfig" do
      context "initialize " do
        setup do
          
          @e1 = Election.find_by_display_name "Election 1"
          @p1 = Precinct.find_by_display_name "Precint 1"
          
          @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => true)
          @ballot_config = DefaultBallot::BallotConfig.new( @e1, @template)
          
          @pdf = create_pdf("Test Default Ballot")
          @ballot_config.setup(@pdf, @p1)
          
        end # end setup
        
        should "create a ballot config " do
          assert @ballot_config
          assert_instance_of DefaultBallot::BallotConfig, @ballot_config
        end

#         should "create a checkbox outline " do
#           # in about the middle of the page
#           @ballot_config.stroke_checkbox([@pdf.bounds.top/2, @pdf.bounds.right/2])
#           @pdf.render_file("#{Rails.root}/tmp/ballot_stroke_form_checkbox.pdf")
#         end
        
        should "draw 3 checkboxes, one in each column" do
          # bounding rect of pdf page
          rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)

          # split the page into 3 columns
          three_columns = TTV::Ballot::Columns.new(3, rect)

          first_column = three_columns.next
          @ballot_config.draw_checkbox(first_column, "This is a test checkbox in column 1")
          
          2.times do |column_num|
            @ballot_config.draw_checkbox(three_columns.next, "This is a test checkbox in column #{column_num+2}")
          end
          util = TTV::Prawn::Util.new(@pdf)

          @pdf.render_file("#{Rails.root}/tmp/ballot_draw_form_checkbox.pdf")
        end


      end # end initialize context
      
    end # end Default::BallotConfig context
    
  end # end setup_jurisdictions
end
