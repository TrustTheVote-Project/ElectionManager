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
      puts "TGD: form = #{form.inspect}"

      fields = get_fields(form)
      puts "TGD: fields = #{fields.inspect}"

      
      textfield = fields.first
      puts "TGD: textfield =  #{textfield.inspect}" 
      
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
    
  end # end context
end
