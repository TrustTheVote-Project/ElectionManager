require 'test_helper'
require 'ballots/dc/ballot_config.rb'


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
      @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/global_style_1.yml")
      @pdf = create_document(@template)
      
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
        @template[:ballot_layout][:questions_placement] = :at_end

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
