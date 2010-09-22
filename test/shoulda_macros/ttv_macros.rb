# from http://szeryf.wordpress.com/2010/03/01/custom-shoulda-macros-a-tutorial/
class Test::Unit::TestCase

  # Usage
  #   class PostTest
  #     should_have_attr_reader :comments_number
  #   end
  def self.should_have_attr_reader name
    # get the name of the class under test from the current class
    klass = self.name.gsub(/Test$/, '').constantize
    
    should "have attr_reader :#{name}" do
      # create and instance of this class
      obj = klass.new
      # set the instance variable identified by the name parameter
      # for this object to "SomeSecretValue"
      #obj.instance_variable_set("@#{name}", "SomeSecretValue")
      # FIX:  instance_variable_set doesn't work??
      obj.send("#{name}=", "SomeSecretValue")
      # read the instance variable using the name method
      # and assert it's what we just set using instance_variable_set
      assert_equal("SomeSecretValue", obj.send(name))
    end
  end
  
  def create_pdf(title = "Test PDF", options={})
    @pdf_title = title
    @pdf_creator = "TrustTheVote"

    options = { :page_layout => :portrait,
      # LETTER
      # width =  612.00 points
      # length = 792.00  points
      :page_size => "LETTER",
      :left_margin => 18,
      :right_margin => 18,
      :top_margin => 30,
      :bottom_margin => 30,
      # :skip_page_creation => true,
      :info => { :Creator => @pdf_creator,
        :Title => @pdf_title
      }}.merge(options)
    
    Prawn::Document.new(options)

  end
  
  def create_pdf_from_template(template, election, precinct)
    @pdf = ::Prawn::Document.new( :page_layout => template.page[:layout], 
                                  :page_size => template.page[:size],
                                  :left_margin => template.page[:margin][:left],
                                  :right_margin => template.page[:margin][:right],
                                  :top_margin =>  template.page[:margin][:top],
                                  :bottom_margin =>  template.page[:margin][:bottom],
                                  :skip_page_creation => true,
                                  :info => { :Creator => "TrustTheVote",
                                    :Title => "#{election.display_name}  #{precinct.display_name} ballot"} )

  end

  
  def print_bounds(bounds)
    puts "TGD: absolute top, left, bottom and right = #{bounds.absolute_top.inspect}, #{bounds.absolute_left.inspect}, #{bounds.absolute_bottom.inspect}, #{bounds.absolute_right.inspect}"
    puts "TGD: top, left, bottom and right = #{bounds.top.inspect}, #{bounds.left.inspect}, #{bounds.bottom.inspect},  #{bounds.right.inspect}"
  end
  
  def render_and_find_objects(pdf)
    output = StringIO.new(pdf.render, 'r+')
    @hash = PDF::Hash.new(output)
    @pages = @hash.values.find {|obj| obj.is_a?(Hash) && obj[:Type] == :Pages}[:Kids]
    @producer = @hash.values.map {|obj| obj[:Producer] if obj.is_a?(Hash) && obj[:Producer]}.first
    @creator = @hash.values.map {|obj| obj[:Creator] if obj.is_a?(Hash) && obj[:Creator] }.first
    @title = @hash.values.map {|obj| obj[:Title] if obj.is_a?(Hash) && obj[:Title] }.first
    @text = @hash.values.find {|obj|obj.unfiltered_data if obj.is_a?(PDF::Reader::Stream) }
    # @creator =  Iconv.iconv('UTF-8', "UTF-16", @creator).first
    # @producer =  Iconv.iconv('UTF-8', "UTF-16", @producer).first
    # @title =  Iconv.iconv('UTF-8', "UTF-16", @title).first
  end
  
  def pdf_hash(pdf)
    output = StringIO.new(pdf.render, 'r+')
    @hash = PDF::Hash.new(output)    
    str = ""
    @hash.each do |ref, obj|
      str << "\nref = #{ref.inspect}"
      str << "\nobj = #{obj.inspect}"
      str << "\n" << '-'*15
    end
    str
  end
  
  # given a reference id return hash representation of it's object
  def get_obj(ref_id)
    @hash.each do |ref, obj|
      return obj if ref.id == ref_id
    end
  end

  # get the form, AcroForm
  # return - Hash for form
  # {:DR=>9, :Fields=>[#<PDF::Reader::Reference:0x105a66098 @id=7, @gen=0>], :DA=>"/Helv 0 Tf 0 g"}
  def get_form
    acroform_ref = @hash.values.map {|obj| obj[:AcroForm] if obj.is_a?(Hash) && obj[:AcroForm] }.compact.first
    get_obj(acroform_ref.id)
  end
  
  # get all of a pdf forms fields
  # form - hash for form, see get_form
  # return - Array of hashes that represent each field in the form
  # [{:Type=>:Annot, :Rect=>[100, 600, 600, 616], :BS=>{:Type=>:Border, :W=>1, :S=>:S}, :Ff=>0, :DA=>"/Helv 0 Tf 0 g", :T=>"fname", :FT=>:Tx, :Subtype=>:Widget, :MK=>{:BC=>[0, 0, 0]}, :F=>4}]
  def get_fields(form)
    form[:Fields].map do |ref|
      field_hash = get_obj(ref.id)
    end
  end
  
  def create_question(name, district, election, text)
    question = Question.make(:display_name => name,
                                 :election => election,
                                 :requesting_district => district,
                                 :question => text)
  
  end
  
  def create_contest(name, voting_method, district, election, position = 0)
    contest = Contest.make(:display_name => name,
                           :voting_method => voting_method,
                           :district => district,
                           :election => election,
                           :position => position,
                           :ident => "ident-#{name}")
    
    position += 1
    [:democrat, :republican, :independent].each do |party_sym|
      party = Party.make(party_sym)
      Candidate.make(:party => party, :display_name => "#{name}_#{party_sym.to_s[0..2]}", :contest => contest, :ident => "ident-#{name}_#{party_sym.to_s[0..2]}_#{contest.display_name}")
    end
    contest
  end

  def create_ballot_config(pdf_form = false)
    @scanner = TTV::Scanner.new
    @election = Election.make(:display_name => "Election 1" )
    
    @district = District.make(:display_name => "District 1")
    @precint = Precinct.make(:display_name => "Precinct 1")

    @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => pdf_form)
    @ballot_config = DefaultBallot::BallotConfig.new( @election, @template)
    
    @ballot_config.setup(create_pdf("Test PDF"), @precinct) # don't need the 2nd arg precinct
    @pdf = @ballot_config.pdf
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
    
    frame[:content][:right][:graphics] = <<-'CONTENT_RIGHT'

      @pdf.font "Courier"
      text = @frame[:content][:right][:text]
      middle_x = @pdf.bounds.right - @frame[:content][:right][:width]/2
      middle_y = @pdf.bounds.height/2 + @pdf.width_of(text)/2
      @pdf.draw_text text, :at => [middle_x, middle_y], :rotate => -90

    CONTENT_RIGHT
    
    frame[:content][:left][:graphics] = <<-'CONTENT_LEFT'
      @pdf.font "Courier"
      text = @frame[:content][:right][:text]
      middle_x = @frame[:content][:left][:width]/2
      middle_y = @pdf.bounds.height/2 - @pdf.width_of(text)/2
      @pdf.draw_text text, :at => [middle_x, middle_y], :rotate => 90
    CONTENT_LEFT
    
    frame
  end
  
  def ballot_contents
    
    contents = {
      :border => {:width => 2, :color => '#00000F', :style => :dashed},
      
      :header =>{
        :width => 400, # % width of ballot contents box
        :height => 100, # % height of ballot contents box
        :margin => {:top => 10, :right => 10, :bottom => 10, :left => 10},
        :border => {:width => 2, :color => '0000FF', :style => :solid},
        :text => "Header Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#0000FF',
        :graphics => nil
      },
      
      :footer =>{
        # :width => 1.0, # % width of ballot contents box
        # :height => 0.15, # % height of ballot contents box
        :width => 400, # % width of ballot contents box
        :height => 50, # % height of ballot contents box
        :margin => {:top => 10, :right => 10, :bottom => 10, :left => 10},
        :border => {:width => 2, :color => 'FF0000', :style => :solid},
        :text => "Footer Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#00FF00',
        :graphics => nil
      },
      
      :body =>{
        #:width => 1.0, # % width of ballot contents box
        #:height => 0.7, # % height of ballot contents box
        :width => 400, # % width of ballot contents box
        :height => 400, # % height of ballot contents box
        :margin => {:top => 10, :right => 10, :bottom => 10, :left => 10},
        :border => {:width => 1, :color => '00FF00', :style => :solid},
        :text => "Body Text", # this will be Rich Text in Prawn 1.0
        :background_color => '#FF0000',
        :graphics => nil
      }
      
    }
    
    contents[:header][:graphics] = <<-'HEADER'
      @pdf.font "Helvetica"
      text = @contents[:header][:text]
      middle_x = @pdf.bounds.width/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.height/2 - @pdf.height_of(text)/2
      @pdf.draw_text text, :at => [middle_x, middle_y]
    HEADER
    
    contents[:body][:graphics] = <<-'BODY'
      @pdf.font "Helvetica"
      text = @contents[:body][:text]
      middle_x = @pdf.bounds.width/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.height/2 - @pdf.height_of(text)/2
      @pdf.draw_text text, :at => [middle_x, middle_y]
    BODY
    
    contents[:footer][:graphics] = <<-'FOOTER'
      @pdf.font "Helvetica"
      text = @contents[:footer][:text]
      middle_x = @pdf.bounds.width/2 - @pdf.width_of(text)/2
      middle_y = @pdf.bounds.height/2 - @pdf.height_of(text)/2
      @pdf.draw_text text, :at => [middle_x, middle_y]
    FOOTER

    contents
  end
  
  def setup_ballot
    d1 = District.make(:display_name => "District 1", :district_type => DistrictType::COUNTY)
    d2 = District.make(:display_name => "District 2", :district_type => DistrictType::COUNTY)

    # create a jurisdiction with only the first 2 districts 
    ds1  = DistrictSet.make(:display_name => "District Set 1")
    ds1.districts << d1
    ds1.districts << d2
    ds1.jur_districts << d1
    
    p1 = Precinct.make(:display_name => "Precinct 1", :jurisdiction => ds1)
    # TODO: what happens when a precinct p1 has a different
    # jurisdiction/district_set that one of it's precincts?
    @prec_split = PrecinctSplit.make(:display_name => "Precinct Split 1", :precinct => p1, :district_set => ds1)
    p1.precinct_splits << @prec_split

    # make an election for this jurisdiction
    @election = Election.create!(:display_name => "Election 1", :district_set => ds1)
    @election.start_date = DateTime.new(2009, 11,3)

    # Create 3 contests for this election
    pos = 0;
    ["Contest 1", "Contest 2", "Contest 3", "State Rep", "Attorney General","Governor"].each do |contest_name|
      contest = create_contest(contest_name,
                               VotingMethod::WINNER_TAKE_ALL,
                               @election.district_set.jur_districts.first,
                               @election, pos)
      pos += 1
    end
    
    Question.make(:display_name => "Dog Racing",
                  :election => @election,
                  :requesting_district => @election.district_set.districts.first,
                  :question => 'This proposed law would prohibit any dog racing or racing meeting in Massachusetts where any form of betting or wagering on the speed or ability of dogs occurs. The State Racing Commission would be prohibited from accepting or approving any application or request for racing dates for dog racing. Any person violating the proposed law could be required to pay a civil penalty of not less than $20,000 to the Commission. The penalty would be used for the Commission\'s administrative purposes, subject to appropriation by the state Legislature. All existing parts of the chapter of the state\'s General Laws concerning dog and horse racing meetings would be interpreted as if they did not refer to dogs. These changes would take effect January 1, 2010. The proposed law states that if any of its parts were declared invalid, the other parts would stay in effect.' )
    
    scanner = TTV::Scanner.new
    @template = BallotStyleTemplate.make(:display_name => "test template")
    #@template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => true)
    
    # @template.page = ballot_page
    # @template.frame = ballot_frame
    # @template.contents = ballot_contents
    
    @ballot_config = ::DcBallot::BallotConfig.new( @election, @template)

    @pdf = create_pdf("Test Renderer")
    @ballot_config.setup(@pdf, p1)
    

    destination = nil
    
    # @renderer = AbstractBallot::Renderer.new(@election, p1, @ballot_config, destination)
    @renderer = AbstractBallot::Renderer.new(@election, @prec_split, @ballot_config, destination)

  end
  
end
