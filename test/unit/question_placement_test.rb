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


class QuestionPlacementTest < ActiveSupport::TestCase

  context "Create Flow Items" do
    
    setup do
      # create a juris with 9 districts, 1 election, 1 precinct and a
      # precinct_split with 3 districts
      create_election_with_precincts
      
      #create 3 contests for each of the 3 @precinct_split's districts
      @contest_count = 3
      create_contests(@contest_count)

      #create 2 questions for each of the 3 @precinct_split's districts
      @question_count = 2
      create_questions(@question_count)

      # BallotStyle Template that is not a form
      @template = BallotStyleTemplate.make(:display_name => "BallotStyleTemplate", :pdf_form => false)
      
      # Load the ballot style sheet
      # @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/global_style_1.yml")
      @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/test_stylesheet.yml")

      @pdf = create_document(@template)
      @election.ballot_style_template_id = @template.id
      # @election.save!
      @flow_items = DefaultBallot::FlowItem.init_flow_items(@pdf, @election, @precinct_split, @template)
      
    end

    should "have the correct number of flow items" do
      assert @flow_items
      district_count = @precinct_split.district_set.districts.size
      assert_equal district_count * (@contest_count + @question_count), @flow_items.size
    end

    should "have combo flows, one for each district" do
      combo_count = @flow_items.inject(0) do |sum, item|
        #puts "flow item = #{item.class.name}"
        item.class.name == "DefaultBallot::FlowItem::Combo" ? sum += 1 : sum
      end
      # 3 districts
      district_count = @precinct_split.district_set.districts.size
      # combo flows
      assert_equal district_count, combo_count
    end

        should "have header flows, one for each district" do
          header_count = @flow_items.inject(0) do |sum, item|
            if item.class.name == "DefaultBallot::FlowItem::Combo"
              combo_flow_items = item.instance_variable_get(:@flow_items)
              #puts "flow item = #{combo_flow_items.first.class.name}"
              combo_flow_items.first.class.name == "DefaultBallot::FlowItem::Header" ? sum += 1 : sum
            end
            sum
          end
          # 3 districts, 3 header flows
          district_count = @precinct_split.district_set.districts.size
          # combo flows
          assert_equal district_count, header_count
        end
    
        should "order contest and questions by district" do
          actual_order = []
          @flow_items.each do |item|
            actual_order << item.class.name.split('::').last
          end
    
          # puts "actual_order = #{actual_order.inspect}"
          # 3 districts each with 3 contests and 2 questions. The first
          # contest in each district is part of the combo flow.
          expected_order = ["Combo", "Contest", "Contest", "Question", "Question", "Combo", "Contest", "Contest", "Question", "Question", "Combo", "Contest", "Contest", "Question", "Question"]
          assert_equal expected_order.size, actual_order.size
          assert_same_elements expected_order, actual_order
          assert_equal expected_order, actual_order
        end
    
        should "render the flow items in the default order " do
          @ballot_config = ::DcBallot::BallotConfig.new( @election, @template)
          @renderer = AbstractBallot::Renderer.new(@election, @precinct_split, @ballot_config, nil)
          @renderer.render
          pdf = @renderer.instance_variable_get(:@pdf)
          pdf.render_file("#{Rails.root}/tmp/flow_item_default_order.pdf")
        end
    
        context "Flow Items re-order" do
          setup do
        @template.ballot_layout['questions_placement'] = :at_end
    
            @flow_items = DefaultBallot::FlowItem.init_flow_items(@pdf, @election, @precinct_split, @template)
          end
    
          should "place questions after contests" do
            actual_order = []
            @flow_items.each do |item|
              actual_order << item.class.name.split('::').last
            end
            # puts "actual_order = #{actual_order.inspect}"
    
            expected_order = ["Combo", "Contest", "Contest", "Combo", "Contest", "Contest", "Combo", "Contest", "Contest", "Question", "Question", "Question", "Question", "Question", "Question"]
            assert_equal expected_order, actual_order
    
          end
    
          should "render the flow items in the with questions after all contest " do
            @ballot_config = ::DcBallot::BallotConfig.new( @election, @template)
            @renderer = AbstractBallot::Renderer.new(@election, @precinct_split, @ballot_config, nil)
            @renderer.render
            pdf = @renderer.instance_variable_get(:@pdf)
            pdf.render_file("#{Rails.root}/tmp/flow_item_questions_last_order.pdf")
          end
        end # context Flow Items re-order
    
  end # context Create Flow Items
  
end
