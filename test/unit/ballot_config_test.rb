require 'test_helper'
require 'ballots/default/ballot_config'

class BallotConfigTest < ActiveSupport::TestCase
  setup_jurisdictions do  
    
    context "Default::BallotConfig" do
      context "initialize " do
        setup do
          
          @e1 = Election.find_by_display_name "Election 1"
          @p1 = Precinct.find_by_display_name "Precinct 1"
          
          # TODO: create a test for ballot_instructions, it's
          # commented out below
          # @template = BallotStyleTemplate.make(:display_name => "test template", :instructions_image_file_name => "instructions.jpg", :instructions_image_file_size => 182537, :instructions_image_content_type => 'jpg')
          
          @template = BallotStyleTemplate.make(:display_name => "test template")
          
          @ballot_config = DefaultBallot::BallotConfig.new( @e1, @template)
          
          @pdf = create_pdf("Test Default Ballot")
          
          @ballot_config.setup(@pdf, @p1)

          # remove all the pdf in the tmp dir
          # FileUtils.rm "#{Rails.root}/tmp/*.pdf", :force => true
          
        end # end setup
        
        should "set the correct ballot directory " do
          style = BallotStyle.find(@template.ballot_style).ballot_style_code
          assert_equal  "#{Rails.root}/app/ballots/#{style}", @ballot_config.instance_variable_get(:@file_root) 
        end
        
        should "set the correct ballot translation" do
          assert_instance_of TTV::Translate::YamlTranslation, @ballot_config.instance_variable_get(:@ballot_translation)           
        end
        
        should "set the correct election translation" do
          assert_instance_of TTV::Translate::ElectionTranslation, @ballot_config.instance_variable_get(:@election_translation)           
        end
        
        should "create a ballot config " do
          assert @ballot_config
        end

        #TODO: load_test method doesn't seem to be used anywhere
        should "load the ballot file for the language code \"en\"" do
          assert_nothing_raised do
            @ballot_config.load_text("ballot.yml")
          end
          
          assert_raise Errno::ENOENT do
            @ballot_config.load_text("fubar.yml")
          end
        end
      
        # TODO: remove as it doesn't seem to be used?      
        should "load the image for language code \"en\"" do
          assert_nothing_raised do
            @ballot_config.load_image("instructions2.png")          
          end
        end
        
        should "get a ballot translation" do
          assert_instance_of TTV::Translate::YamlTranslation, @ballot_config.ballot_translation
          assert_instance_of TTV::Translate::YamlTranslation, @ballot_config.bt           
        end

        should "get a election translation" do
          assert_instance_of TTV::Translate::ElectionTranslation, @ballot_config.election_translation
          assert_instance_of TTV::Translate::ElectionTranslation, @ballot_config.et
        end

        should "create a pdf continuation box" do
          assert_instance_of DefaultBallot::ContinuationBox, @ballot_config.create_continuation_box
          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n", util.page_contents[0]
          @pdf.render_file("#{Rails.root}/tmp/ballot_create_continuation_box.pdf")
        end
        
        should "create 3 columns in the ballot" do
          flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
          assert_instance_of AbstractBallot::Columns, @ballot_config.create_columns(flow_rect)
        end
        
        should "have a wide style of continue" do
          assert_equal :continue, @ballot_config.wide_style 
        end

        should "create a checkbox outline " do
          # in about the middle of the page
          @ballot_config.stroke_checkbox([@pdf.bounds.top/2, @pdf.bounds.right/2])
          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n384.000 308.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n", util.page_contents[0]

          @pdf.render_file("#{Rails.root}/tmp/ballot_stroke_checkbox.pdf")
        end
        
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
          
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n40.000 728.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n68.0 730.72 Td\n/F1.0 10 Tf\n<546869732069732061207465737420636865636b626f7820696e> Tj\nET\n\n\nBT\n68.0 720.04 Td\n/F1.0 10 Tf\n<636f6c756d6e2031> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n240.000 728.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n268.0 730.72 Td\n/F1.0 10 Tf\n<546869732069732061207465737420636865636b626f7820696e> Tj\nET\n\n\nBT\n268.0 720.04 Td\n/F1.0 10 Tf\n<636f6c756d6e2032> Tj\nET\n\n1.5 w\n1.000 1.000 1.000 scn\n0.000 0.000 0.000 SCN\n440.000 728.000 22.000 10.000 re\nb\n0.000 0.000 0.000 scn\n\nBT\n468.0 730.72 Td\n/F1.0 10 Tf\n<546869732069732061207465737420636865636b626f7820696e> Tj\nET\n\n\nBT\n468.0 720.04 Td\n/F1.0 10 Tf\n<636f6c756d6e2033> Tj\nET\n\n", util.page_contents[0]

          @pdf.render_file("#{Rails.root}/tmp/ballot_draw_checkbox.pdf")
        end

        should "draw a frame item, rectangle with 3 sides " do
          # should be a rectangle without a line on the bottom.
          #
          # 3 line from:
          # [0, top-100] to [right -100, top -100] at top of rect
          # [right -100, top -100] to [right -100, top - 400] on right of rect
          # [0, top-100] to [0, top - 400] on left of rect
          # top, left, bottom and right
          rect = AbstractBallot::Rect.create(@pdf.bounds.top-100,0, 0, @pdf.bounds.right-100 )
          @ballot_config.frame_item(rect, rect.height-300 )
          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n0.5 w\n18.000 662.000 m\n494.000 662.000 l\nS\n494.000 662.000 m\n494.000 362.000 l\nS\n18.000 662.000 m\n18.000 362.000 l\nS\n", util.page_contents[0]

          @pdf.render_file("#{Rails.root}/tmp/ballot_frame_item.pdf")
        end
        
        # - render the 4 filled in rectangles on the edges of the ballot
        # - render a smaller box inside the page
        # - draw text vertically on the left and right edges of the
        # page. This text in contained in the ballot xlation file at
        # app/ballots/default/lang/en/ballot.yml
        # - draw some long, hard coded, numbers vertically on the left
        # and right edges of the page
        should "render a frame around the entire page" do
          flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
          @ballot_config.render_frame flow_rect
          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n1.000 1.000 0.000 scn\nf\n0.000 0.000 0.000 scn\n0.000 0.000 0.000 scn\n18.000 30.000 18.000 140.000 re\n18.000 622.000 18.000 140.000 re\n576.000 30.000 18.000 140.000 re\n576.000 622.000 18.000 140.000 re\nb\n44.000 95.000 524.000 672.000 re\nS\n\nBT\n0.000 1.000 -1.000 0.000 34.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 370.000 Tm\n/F1.0 14 Tf\n<53616d706c652042616c6c6f74> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 34.000 505.000 Tm\n/F1.0 14 Tf\n<3132303031303430313030303430> Tj\nET\n\n\nBT\n0.000 1.000 -1.000 0.000 592.000 241.000 Tm\n/F1.0 14 Tf\n<313332333031313133> Tj\nET\n\n", util.page_contents[0]
          @pdf.render_file("#{Rails.root}/tmp/ballot_render_frame.pdf")          
        end
        
        should "render a header with an old date for this page" do
          flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
          
          # make sure the election has a start date
          @e1.start_date = DateTime.new(2009, 11,3)
          
          @ballot_config.render_header flow_rect
          
          @pdf.render_file("#{Rails.root}/tmp/ballot_render_header.pdf")

          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n\nBT\n26 749.536 Td\n/F1.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n26 735.405 Td\n/F1.0 13 Tf\n<4e6f76656d6265722030322c2032303039> Tj\nET\n\n\nBT\n373.999666666667 749.536 Td\n/F1.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n373.622666666667 735.405 Td\n/F1.0 13 Tf\n<50726563696e63742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n18.000 728.738 m\n594.000 728.738 l\nS\nQ\n", util.page_contents[0]
          
        end
        
        should "render a header for this page" do
          # should see a header with:
          # - Official Ballot text in upper left
          # - Today's Date under that
          # - Election display name in the upper rigth
          # - Precinct display name under that
          # - Line directly underneath the above
          
          flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
          
          # make sure the election has a start date
          @e1.start_date = DateTime.new(2009, 7, 25)
          
          @ballot_config.render_header flow_rect

          @pdf.render_file("#{Rails.root}/tmp/ballot_render_header.pdf")
          
          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n\nBT\n26 749.536 Td\n/F1.0 13 Tf\n[<4f4646494349414c> 18.06640625 <2042414c4c4f54>] TJ\nET\n\n\nBT\n26 735.405 Td\n/F1.0 13 Tf\n<4a756c792032342c2032303039> Tj\nET\n\n\nBT\n373.999666666667 749.536 Td\n/F1.0 13 Tf\n<456c656374696f6e2031> Tj\nET\n\n\nBT\n373.622666666667 735.405 Td\n/F1.0 13 Tf\n<50726563696e63742031> Tj\nET\n\n0.000 0.000 0.000 SCN\n18.000 728.738 m\n594.000 728.738 l\nS\nQ\n", util.page_contents[0]

        end
        
        # render the column instruction image in the leftmost column
        should "not render column instructions" do
          # bounding rect of pdf page
          rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)

          # split the page into 3 columns
          three_columns = AbstractBallot::Columns.new(3, rect)
          page = 1
          @ballot_config.render_column_instructions(three_columns, page)
          
          util = TTV::Prawn::Util.new(@pdf)
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n0.5 w\n", util.page_contents[0]
          
          @pdf.render_file("#{Rails.root}/tmp/ballot_not_render_column_instructions.pdf")

        end

#         # render the column instruction image in the leftmost column
#         should "render column instructions" do
#           # bounding rect of pdf page
#           rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)

#           # split the page into 3 columns
#           three_columns = AbstractBallot::Columns.new(3, rect)
#           page = 1
#           @ballot_config.render_column_instructions(three_columns, page)
#           util = TTV::Prawn::Util.new(@pdf)
#           assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n\nq\n172.000 0 0 600.000 20.000 161.000 cm\n/I1 Do\nQ\n0.5 w\n", util.page_contents[0]
#           @pdf.render_file("#{Rails.root}/tmp/ballot_render_column_instructions.pdf")          
          
#         end
        
        # render the column instruction image in the leftmost column
        should "page complete will show \"Vote Both Sides\" if not the last page of the ballot " do
          page_num = 33
          last_page = false
          @ballot_config.page_complete(page_num, last_page)

          util = TTV::Prawn::Util.new(@pdf)
          #assert_equal 'foo', util.page_contents[0]
          assert_equal "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n\nBT\n252.90653125 751.808 Td\n/F1.0 14 Tf\n[<56> 74.21875 <6f746520426f7468205369646573>] TJ\nET\n\n\nBT\n252.90653125 39.808 Td\n/F1.0 14 Tf\n[<56> 74.21875 <6f746520426f7468205369646573>] TJ\nET\n\n", util.page_contents[0]

          @pdf.render_file("#{Rails.root}/tmp/ballot_page_complete.pdf")   

        end

      end # end initialize context
      
    end # end Default::BallotConfig context
    
  end # end setup_jurisdictions
end
