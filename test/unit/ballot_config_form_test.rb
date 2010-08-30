require 'test_helper'
require 'ballots/default/ballot_config'

class BallotConfigTest < ActiveSupport::TestCase
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
          rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)

          # split the page into 3 columns
          three_columns = AbstractBallot::Columns.new(3, rect)

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
