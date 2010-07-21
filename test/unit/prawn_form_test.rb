require 'test_helper'

class PrawnFormTest < ActiveSupport::TestCase

  context "TTV::Form" do

    setup do
      @pdf =  create_pdf("Test Form Text Field")
    end

    should "extend Prawn::Document " do
      assert @pdf
      assert_equal "This worked", @pdf.test_method
    end

    should "generate a text field" do
      
      x = 100; y = 600; w = 500; h = 16
      @pdf.draw_text("First Name:", :at => [x, y+10], :size => 12)
      assert @pdf.text_field("fname", x, y, w, h)
      #puts "TGD: " << @pdf.show_obj_store
      #puts "TGD: " << pdf_hash(@pdf)

      render_and_find_objects(@pdf)
      
      form =  get_form()
      #puts "TGD: form = #{form.inspect}"

      fields = get_fields(form)
      #puts "TGD: fields = #{fields.inspect}"

      
      textfield = fields.first
      #puts "TGD: textfield =  #{textfield.inspect}" 
      
      assert_equal 9, form[:DR]
      assert_equal '/Helv 0 Tf 0 g', form[:DA]

      assert_equal :Tx, textfield[:FT]
      assert_equal :Annot, textfield[:Type]
      assert_equal 0, textfield[:Ff]
      assert_equal 'fname', textfield[:T]
      assert_equal '/Helv 0 Tf 0 g', textfield[:DA]
      assert_equal :Widget, textfield[:Subtype]
      assert_equal 4, textfield[:F]
      # add origin to width and height
      assert_equal [x,y,w+x,h+y], textfield[:Rect]
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_form_text_field.pdf"
    end
    
    should "generate an empty form" do
      # generate an empty form
      @pdf.form

      # use PDF:Reader to get PDF contents
      render_and_find_objects(@pdf)
      form =  get_form()
      
      # puts "TGD: form = #{form.inspect}"

      # check for the form's default resource directory (DR)
      resources =  get_obj(form[:DR])
      # puts "TGD: form.resources = #{resources.inspect}"
      assert_equal :Font, resources[:Type]
      assert_equal :WinAnsiEncoding, resources[:Encoding]
      assert_equal :Helvetica, resources[:BaseFont]
      assert_equal :Type1, resources[:Subtype]

      # check for the form's default appearance (DA)
      assert_equal '/Helv 0 Tf 0 g', form[:DA]

      # should not have any Fields yet
      assert form[:Fields].empty?
    end

    should "be able to change resources" do
      # generate an empty form
      @pdf.form do
        # change the base font to ariel
        resources(:BaseFont => :Ariel)
      end

      render_and_find_objects(@pdf)
      form =  get_form()
      
      # check for the form's default resource directory (DR)
      resources =  get_obj(form[:DR])
      assert_equal :Font, resources[:Type]
      assert_equal :WinAnsiEncoding, resources[:Encoding]
      assert_equal :Type1, resources[:Subtype]

      # changed resource
      assert_equal :Ariel, resources[:BaseFont]

    end

    should "be able to add a text field " do
      
      # text box origin(x,y), width and height
      x = 100; y = 600; w = 500; h = 16
      tbox_content = "My Very Own Text Box"
      partial_name = "Partial Field Name"

      @pdf.form do
        # add fields
        fields do
          # add a text field to the form
          text_field2(partial_name, x, y, w, h, :default => tbox_content)        
        end
        # add a text field to the form
      end
      
      # use PDF:Reader to get PDF contents
      render_and_find_objects(@pdf)
      form =  get_form()
      # get the first field created above
      textfield =  get_obj(form[:Fields].first)
      puts "TGD: field = #{textfield.inspect}"
      
      # Text field dictionary
      # shb a text field
      assert_equal :Tx, textfield[:FT]
      # partial name
      assert_equal partial_name, textfield[:T]
      # default appearance
      assert_equal '/Helv 0 Tf 0 g', textfield[:DA]
      # field flag, not read only, not required, can be exported
      assert_equal 0, textfield[:Ff]
      # field's value
      assert_equal tbox_content, textfield[:V]
      assert_equal 4, textfield[:F]

      # Annotation dictionary
      # This text field is also used as an annotation dictionary
      assert_equal :Annot, textfield[:Type]
      # a Widget annotation directory
      assert_equal :Widget, textfield[:Subtype]
      # at this location in user space, which includes the page's
      # margins offset
      assert_equal [x,y,w+x,h+y], textfield[:Rect]
      # the border color is white ([0,0,0]) [R,G,B]
      assert_equal [0,0,0], textfield[:MK][:BC]
      # the border style is solid 
      assert_equal :S, textfield[:BS][:S]
      # the border style is 1 point wide
      assert_equal 1, textfield[:BS][:W]

      @pdf.render_file "#{Rails.root}/tmp/prawn_form_text_field2.pdf"
    end
    
  end # end context
end
