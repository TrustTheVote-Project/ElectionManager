require 'test_helper'
require 'ballots/dc/ballot_config'

class BallotStyleSheetPageTest < ActiveSupport::TestCase
  context "initialize" do
    setup do
      create_election_with_precincts
      create_contests(3)
      create_questions(2)
      @template = BallotStyleTemplate.make(:display_name => "BallotStyleTemplate", :pdf_form => false)

      # TODO: may want to move this to test/fixtures?
      # test stylesheet
      fname = "#{Rails.root}/test/unit/data/newballotstylesheet/test_stylesheet.yml"
      @expected_styles = {}
      File.open(fname) do |yaml_file|
        @expected_styles = YAML.load(yaml_file)
      end
      @template.load_style(fname)
      # @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/global_style_1.yml")
    end # end setup
    
    should "have been updated after loading styles" do
      bst = BallotStyleTemplate.find(@template.id)
      assert_equal @template.id, bst.id
      assert_equal @template.page, bst.page
      assert_equal @template.frame, bst.frame
      assert_equal @template.contents, bst.contents
      assert_equal @template.ballot_layout, bst.ballot_layout
      
    end
    
    should "have the correct frame attributes" do
      assert_equal 50, @template.frame['margin']['top']
      assert_equal 40, @template.frame['margin']['right']
      assert_equal 30, @template.frame['margin']['bottom']
      assert_equal 20, @template.frame['margin']['left']
    end
    
    should "have the expected frame margin attributes" do
      assert_equal @expected_styles['frame']['margin']['top'], @template.frame['margin']['top']
      assert_equal @expected_styles['frame']['margin']['right'], @template.frame['margin']['right']
      assert_equal @expected_styles['frame']['margin']['bottom'], @template.frame['margin']['bottom']
      assert_equal @expected_styles['frame']['margin']['left'], @template.frame['margin']['left']
    end
    
     should "have the correct page attributes" do
       assert_equal "LETTER", @template.page['size']
       assert_equal "A43368", @template.page['background_color']
       assert_equal "../test/unit/data/newballotstylesheet/200px-Seal_of_Virginia.png", @template.page['background_watermark_asset_id']
     end

    should "set the page and frame attributes" do
      # TODO: recfactor how the Prawn::Document and the BallotConfig
      # are used. 
      @ballot_config = DcBallot::BallotConfig.new( @election, @template)
      
      # creates a Prawn::Document used to generate the pdf ballot
      # the following 2 steps are typically done in the
      # AbstractBallot::Render#render
      @pdf = create_document(@template)
      @ballot_config.setup(@pdf,@precinct)

      # describes the ballot box model
      draw_ballot_description
      
      @pdf.render_file("#{Rails.root}/tmp/ballot_stylesheet_norender.pdf")
      
      # absolute co-ordinates are offsets from edge of the page
      # puts "TGD: absolute top, right, bottom,left = #{@pdf.bounds.absolute_top},#{@pdf.bounds.absolute_right},#{@pdf.bounds.absolute_bottom},#{@pdf.bounds.absolute_left}"
      
      assert_equal @pdf.bounds.absolute_top, @doc_height - @template.frame['margin']['top']
      assert_equal @pdf.bounds.absolute_right, @doc_width - @template.frame['margin']['right']
      assert_equal @pdf.bounds.absolute_bottom,  @template.frame['margin']['bottom']
      assert_equal @pdf.bounds.absolute_left,  @template.frame['margin']['left']

      # bounding box coordinates
      # bounding box is the frame without it's margin
      # puts "TGD: top, right, bottom, left = #{@pdf.bounds.top},#{@pdf.bounds.right},#{@pdf.bounds.bottom},#{@pdf.bounds.left}"      
      
      assert_equal @pdf.bounds.top, @doc_height - @template.frame['margin']['top'] - @template.frame['margin']['bottom']
      assert_equal @pdf.bounds.height, @pdf.bounds.top
      assert_equal @pdf.bounds.right, @doc_width - @template.frame['margin']['left'] - @template.frame['margin']['right']
      assert_equal @pdf.bounds.width, @pdf.bounds.right
      assert_equal @pdf.bounds.bottom,  0
      assert_equal @pdf.bounds.left, 0
      
      #      TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)
      #flow_rect = TTV::Ballot::Rect.create_bound_box(@pdf.bounds)

      # just some values for prawn geometry
      assert_equal 612, Prawn::Document::PageGeometry::SIZES["LETTER"][0]
      assert_equal 792, Prawn::Document::PageGeometry::SIZES["LETTER"][1]

      # TODO: use PDF::Reader callbacks to verify generated PDF
      # reader = TTV::Prawn::Reader.new(@pdf)
      # puts "TGD: page = #{reader.page(1).inspect}"
      # puts "TGD: page contents = #{reader.page_contents(1).inspect}"
      

    end
  end # intialize context
  
  def draw_ballot_description
    # aliases
    ftm = @template.frame['margin']['top']
    frm =  @template.frame['margin']['right']
    fbm = @template.frame['margin']['bottom']
    flm = @template.frame['margin']['left']

    @pdf.draw_text "Top Frame Margin = #{ftm}", :at => [@pdf.bounds.width/2, @pdf.bounds.height+ ftm/2]
    @pdf.draw_text "Right Frame Margin = #{frm}", :at => [@pdf.bounds.width + frm/2, @pdf.bounds.height/2], :rotate => -90
    @pdf.draw_text "Bottom Frame Margin = #{fbm}", :at => [@pdf.bounds.width/2, - fbm/2]
    @pdf.draw_text "Left Frame Margin = #{flm}", :at => [0-flm/2, @pdf.bounds.width/2], :rotate => 90
    
    # draw red border around the frame
    draw_border 'FF0000' # red border
    @pdf.draw_text "Frame origin [x,y] = [0,0]", :at => [0,0]
    @pdf.draw_text "Page background color = #{@template.page['background_color']}", :at => [@pdf.bounds.width/2,@pdf.bounds.height/2]
    @pdf.draw_text "Red border outlines the Frame", :at => [0,@pdf.bounds.height]
  end
end
