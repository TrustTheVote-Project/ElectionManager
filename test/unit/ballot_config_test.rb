require 'test_helper'
require 'ballots/default/ballot_config.rb'


class BallotConfigTest < ActiveSupport::TestCase
  setup_jurisdictions do  
    
    context "Default::BallotConfig" do
      context "initialize " do
        setup do
          
          @e1 = Election.find_by_display_name "Election 1"
          @p1 = Precinct.find_by_display_name "Precint 1"
          @scanner = TTV::Scanner.new
          @lang = 'en'
          @style = "default"
          image_instructions = 'images/test/instructions.jpg'
          @ballot_config = DefaultBallot::BallotConfig.new(@style, @lang, @e1, @scanner,image_instructions)
          
          @pdf = create_pdf("Test Default Ballot")
          
          @ballot_config.setup(@pdf, @p1)

          # remove all the pdf in the tmp dir
          # FileUtils.rm "#{Rails.root}/tmp/*.pdf", :force => true
          
        end # end setup
        
        should "set the correct ballot directory " do
          assert_equal  "#{Rails.root}/app/ballots/#{@style}", @ballot_config.instance_variable_get(:@file_root) 
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
        should "load the ballot file for the language code #{@lang}" do
          assert_nothing_raised do
            @ballot_config.load_text("ballot.yml")
          end
          
          assert_raise Errno::ENOENT do
            @ballot_config.load_text("fubar.yml")
          end
        end
      
        # TODO: remove as it doesn't seem to be used?      
        should "load the image for language code #{@lang}" do
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
          @pdf.render_file("#{Rails.root}/tmp/ballot_create_continuation_box.pdf")
        end
        
        should "create 3 columns in the ballot" do
          flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
          assert_instance_of AbstractBallot::Columns, @ballot_config.create_columns(flow_rect)
        end

        should "create short instructions for a contest that is winner take all" do
          contest = Contest.make(:voting_method => VotingMethod::WINNER_TAKE_ALL)
          contest.open_seat_count = 1
          ballot_xlation = @ballot_config.short_instructions(contest)
          assert_equal "Vote for 1", ballot_xlation

          contest.open_seat_count = 5
          ballot_xlation = @ballot_config.short_instructions(contest)
          assert_equal "Vote for up to 5", ballot_xlation

        end
        
        should "create short instructions for a contest that is ranked" do
          contest = Contest.make(:voting_method => VotingMethod::RANKED)
          ballot_xlation = @ballot_config.short_instructions(contest)
          assert_equal "Rank the candidates", ballot_xlation
        end
        
        should "create short instructions for a question" do
          assert_equal "Vote yes or no", @ballot_config.short_instructions(Question.make)
        end
        
        should "raise an exception when getting short instructions for any other item" do
          assert_raise RuntimeError do
            @ballot_config.short_instructions(Election.make)
          end
        end
        
        should "have a wide style of continue" do
          assert_equal :continue, @ballot_config.wide_style 
        end

        should "create a checkbox outline " do
          # in about the middle of the page
          @ballot_config.stroke_checkbox([@pdf.bounds.top/2, @pdf.bounds.right/2])
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
          @pdf.render_file("#{Rails.root}/tmp/ballot_render_frame.pdf")          
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
          @e1.start_date = DateTime.now
          
          @ballot_config.render_header flow_rect
          @pdf.render_file("#{Rails.root}/tmp/ballot_render_header.pdf")          
        end

        # render the column instruction image in the leftmost column
        should "render column instructions" do
          # bounding rect of pdf page
          rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)

          # split the page into 3 columns
          three_columns = AbstractBallot::Columns.new(3, rect)
          page = 1
          @ballot_config.render_column_instructions(three_columns, page)
          @pdf.render_file("#{Rails.root}/tmp/ballot_render_column_instructions.pdf")          
          
        end
        
        # render the column instruction image in the leftmost column
        should "page complete will show \"Vote Both Sides\" if not the last page of the ballot " do
          page_num = 33
          last_page = false
          @ballot_config.page_complete(page_num, last_page)
          @pdf.render_file("#{Rails.root}/tmp/ballot_page_complete.pdf")                  
        end

        should "get the Content flow item for Contests" do
          assert_instance_of DefaultBallot::FlowItem::Contest, @ballot_config.create_flow_item(Contest.new)
        end
        
        should "get the Question flow item for Questions" do
          assert_instance_of DefaultBallot::FlowItem::Question, @ballot_config.create_flow_item(Question.new)
        end

        should "get the Header flow item for Strings" do
          assert_instance_of DefaultBallot::FlowItem::Header, @ballot_config.create_flow_item("Header Content String")
        end
        
        should "get the Combo flow item for Arrays" do
          assert_instance_of DefaultBallot::FlowItem::Combo, @ballot_config.create_flow_item([])
        end

      end # end initialize context
      
    end # end Default::BallotConfig context
    
  end # end setup_jurisdictions
end
