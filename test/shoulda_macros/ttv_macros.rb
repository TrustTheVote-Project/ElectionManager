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
end
