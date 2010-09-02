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
  
  def ballot_page
    # see Prawn::Document::PageGeometry
    # LETTER => width = 612.00 pts, heigth= 792.00 pts
    #  612/72, 792/72  where 72 pts/in
    # width = 8.5 in, heigth= 11 in
    page = {}
    page[:size] = "LETTER" 
    page[:layout] = :portrait # :portrait or :landscape
    page[:background] = '#000000'
    page[:margin] = { :top => 30, :right => 18, :bottom => 30, :left => 18}
    page
  end
  
  def ballot_frame
    # MARGIN
    # surrounds the border, size of whitespace surrounding the frame
    # inside the page margin.
    # top, right, bottom, left
    # {:top => 11, :right => 22, :bottom => 15, :left => 30}
    frame = { }
    frame[:margin] = {:top => 30, :right => 30, :bottom => 30, :left => 30}
    
    # BORDER
    # surrounds the padding
    # width, color, style(dotted, dashed, solid)
    # {:width => 2, :color => '#FF0000', :style => :solid}
    frame[:border] = {:width => 2, :color => '#00FF00', :style => :solid}
    # future below
    # width, color, style(dotted, dashed, solid)
    # {:top {:width => 2, :color => '#FF0000', :style => :solid}}
    # frame[:border][:top]  # future
    # frame[:border][:right] # future
    # frame[:border][:bottom] # future
    # frame[:border][:left] # future
    # frame[:border][:top][:width] # future

    # frame contents surrounds the ballot election info. it may have text and graphics
    # width, background_color, text, rotate, graphics
    # :text can be Rich Text Strings as defined in the PDF Spec.
    # OR
    # it can be a Proc of prawn primitives
    # {:left =>
    #   {:width => 33, background_color => '#00FF00',
    #    :text => '<b color="#000000">Sample <i>Ballot</i></b>',
    #    :rotate => 90, # text rotation in degrees
    #    :graphics => <Proc of prawn primitives>
    #   }
    # }

    frame[:content] = {
      :top => { :width => 40, :text => "Sample Ballot", :rotate => 90, :graphics => nil },
      :right => { :width => 40,:text => "   12001040100040         Sample Ballot", :rotate => 90, :graphics => nil },
      :bottom => { :width => 40,:text => "Sample Ballot", :rotate => 90, :graphics => nil },
      :left => { :width => 40,:text => "    132301113              Sample Ballot", :rotate => 90, :graphics => nil }
    }
    
    frame[:content][:right][:graphics] = lambda{ |pdf|

      pdf.font "Courier"
      text = frame[:content][:right][:text]
      middle_x = pdf.bounds.right - frame[:content][:right][:width]/2
      middle_y = pdf.bounds.height/2 + pdf.width_of(text)/2
      pdf.draw_text text, :at => [middle_x, middle_y], :rotate => -90

    }
    
    frame[:content][:left][:graphics] = lambda{ |pdf|
      pdf.font "Courier"
      text = frame[:content][:right][:text]
      middle_x = frame[:content][:left][:width]/2
      middle_y = pdf.bounds.height/2 - pdf.width_of(text)/2
      pdf.draw_text text, :at => [middle_x, middle_y], :rotate => 90
    }        
    
    frame
  end
  
  def ballot_contents
    
    contents = {
      :border => {:width => 2, :color => '#00000F', :style => :dashed},
      
      :header =>{
        :width => 1.0, # % width of ballot contents box
        :height => 0.15, # % height of ballot contents box
        :margin => {:top => 10, :right => 10, :bottom => 10, :left => 10},
        :border => {:width => 2, :color => '#0000FF', :style => :solid},
        :text => "Header Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#0000FF',
        :graphics => nil
      },
      
      :footer =>{
        :width => 1.0, # % width of ballot contents box
        :height => 0.15, # % height of ballot contents box
        :margin => {:top => 10, :right => 10, :bottom => 10, :left => 10},
        :border => {:width => 2, :color => '#0F0000', :style => :solid},
        :text => "Footer Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#00FF00',
        :graphics => nil
      },
      
      :body =>{
        :width => 1.0, # % width of ballot contents box
        :height => 0.7, # % height of ballot contents box
        :margin => {:top => 10, :right => 10, :bottom => 10, :left => 10},
        :border => {:width => 1, :color => '#00FF00', :style => :solid},
        :text => "Body Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#FF0000',
        :graphics => nil
      }
      
    }
    
    contents[:header][:graphics] = lambda do |pdf|
      pdf.font "Helvetica"
      text = contents[:header][:text]
      middle_x = pdf.bounds.width/2 - pdf.width_of(text)/2
      middle_y = pdf.bounds.height/2 - pdf.height_of(text)/2
      pdf.draw_text text, :at => [middle_x, middle_y]
    end
    
    contents[:body][:graphics] = lambda do |pdf|
      pdf.font "Helvetica"
      text = contents[:body][:text]
      middle_x = pdf.bounds.width/2 - pdf.width_of(text)/2
      middle_y = pdf.bounds.height/2 - pdf.height_of(text)/2
      pdf.draw_text text, :at => [middle_x, middle_y]
    end
    
    contents[:footer][:graphics] = lambda do |pdf|
      pdf.font "Helvetica"
      text = contents[:footer][:text]
      middle_x = pdf.bounds.width/2 - pdf.width_of(text)/2
      middle_y = pdf.bounds.height/2 - pdf.height_of(text)/2
      pdf.draw_text text, :at => [middle_x, middle_y]
    end

    contents
  end

end
