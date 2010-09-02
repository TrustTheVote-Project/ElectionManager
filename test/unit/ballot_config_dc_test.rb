require 'test_helper'
require 'ballots/dc/ballot_config'

class BallotConfigTest < ActiveSupport::TestCase
  context "initialize " do
    setup do
      
      @e1 = Election.make(:display_name => "Election 1")
      @p1 = Precinct.make(:display_name => "Precint 1")
      
      @template = BallotStyleTemplate.make(:display_name => "test template")
      
      @template.page = ballot_page
      @template.frame = ballot_frame
      @template.contents = ballot_contents
      
      @c = @ballot_config = DCBallot::BallotConfig.new( @e1, @template)
      @pdf = ::Prawn::Document.new( :page_layout => @template.page[:layout], 
                                   :page_size => @template.page[:size],
                                    :left_margin => @template.page[:margin][:left],
                                    :right_margin => @template.page[:margin][:right],
                                    :top_margin =>  @template.page[:margin][:top],
                                    :bottom_margin =>  @template.page[:margin][:bottom],
                                   :info => { :Creator => "TrustTheVote",
                                   :Title => "#{@e1.display_name}  #{@p1.display_name} ballot"} )
      
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
    
    should "render a frame around the entire page" do
      flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
      @ballot_config.render_frame flow_rect
      util = TTV::Prawn::Util.new(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_render_dc_frame.pdf")          
    end
    
    should "render a contents for this page" do
      flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
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
