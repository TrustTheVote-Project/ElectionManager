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
  
   
  def create_contest(name, voting_method, district, election, position = 0)
    contest = Contest.make(:display_name => name,
                           :voting_method => voting_method,
                           :district => district,
                           :election => election,
                           :position => position)
        
    position += 1
    [:democrat, :republican, :independent].each do |party_sym|
      party = Party.make(party_sym)
      Candidate.make(:party => party, :display_name => "#{name}_#{party_sym.to_s[0..2]}", :contest => contest)
    end
    contest
  end

  def create_ballot_config(pdf_form = false)
    @scanner = TTV::Scanner.new
    @election = Election.make(:display_name => "Election 1" )
      
    @district = District.make(:display_name => "District 1")
    @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => pdf_form)
    @ballot_config = DefaultBallot::BallotConfig.new( @election, @template)
      
    @ballot_config.setup(create_pdf("Test PDF"), nil) # don't need the 2nd arg precinct
    @pdf = @ballot_config.pdf
  end
end
