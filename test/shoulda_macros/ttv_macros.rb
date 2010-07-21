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
    @creator =  Iconv.iconv('UTF-8', "UTF-16", @creator).first
    @producer =  Iconv.iconv('UTF-8', "UTF-16", @producer).first
    @title =  Iconv.iconv('UTF-8', "UTF-16", @title).first
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
  
  # returns a 2 hashes
  # form hash - Contents of the pdf obj referenced by the Acroform entry in the catalog
  # fields hash - The 
  def get_form
    return unless @hash
    
    acroform_ref = nil
    @hash.each do |ref, obj|
      if obj.is_a?(Hash) && obj[:AcroForm] 
        acroform_ref = obj[:AcroForm]
        break
      end
    end
    
    acroform = nil
    @hash.each do |ref, obj|
      if acroform_ref == ref 
        acroform = obj
        break 
      end
    end
    
    fields_ref  = acroform[:Fields].first
    fields = nil
    @hash.each do |ref, obj|
      if fields_ref == ref
        fields = obj
        break
      end
    end
    [acroform, fields]
  end
  
end
