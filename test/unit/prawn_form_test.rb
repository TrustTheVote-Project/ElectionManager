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
      # assert_equal '/Helv 0 Tf 0 g', form[:DA]

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
    
    should "be ab to create a set of radioboxes" do
      x = 100; y = 600; w = 300; h = 100
      partial_name = "internal radioboxes name"
      
      @pdf.form do
        # create a box around the label and text field
        bounding_box([x,y], :width => w, :height => h) do
          stroke_bounds
          top = 0;
          left = 0
          
          label = "Radio Group: "
          draw_text(label, :at =>[left, top])
          x_offset = width_of(label)
          draw_radio_group(partial_name, :at => [ x_offset, top], :width => 10, :height => 10) do |dict|
            y = 40
            draw_text("Choice 1: ", :at => [0, y])
            dict[:Kids] << draw_radiobutton('rb1', :at => [x_offset,y], :selected => true)
                      
            y += 20
            draw_text("Choice 2: ", :at => [0, y])
            dict[:Kids] << draw_radiobutton('rb2', :at => [x_offset,y])
            
            y += 20
            draw_text("Choice 3: ", :at => [0, y])
            dict[:Kids] << draw_radiobutton('rb3', :at => [x_offset,y])            
          end

        end
      end
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_form_draw_radio_buttons.pdf"
    end
    
    should "be able to add one checkbox" do
      
      x = 100; y = 600; w = 300; h = 100
      partial_name = "Internal Checkbox Name"
      
      @pdf.form do
        
        # create a box around the label and text field
        bounding_box([x,y], :width => w, :height => h) do
          # stroke_bounds
          top = 0;
          left = 0
          
          label = "CheckBox 1: "
          draw_text(label, :at =>[left, top])
          
          # draw a checkbox that will be 10 by 10.
          # Selected will have a X inside the box
          # Not selected will have and empty box.
          draw_checkbox(partial_name, :at => [ width_of(label), top], :width => 10, :height => 10)
        end
      end
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_form_draw_one_checkbox.pdf"
    end
    
    should "be able to add one text field " do
      
      # text box origin(x,y), width and height
      
      x = 100; y = 600; w = 300; h = 100
      tbox_content = "My Text Box"
      partial_name = "Partial Field Name"
      
      @pdf.form do
        
        # create a box around the label and text field
        bounding_box([x,y], :width => w, :height => h) do
          stroke_bounds
          top = 0;
          left = 0
          
          label = "Text Box 1: "
          draw_text(label, :at =>[left, top])
          draw_text_field(partial_name, :at => [ width_of(label), top], :width => 100, :default => tbox_content) 
          
        end
      end
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_form_draw_one_text_field.pdf"
    end
    should "be able to add multiple texts field " do
      
      # text box origin(x,y), width and height
      
      x = 100; y = 600; w = 300; h = 100
      tbox_content = "My Text Box"
      partial_name = "Partial Field Name"
      
      @pdf.form do
        # create a box around the label and text field
        bounding_box([x,y], :width => w, :height => h) do
          stroke_bounds
          top = 0;
          left = 0
          
          label = "Text Box 1: "
          draw_text(label, :at =>[left, top])
          draw_text_field(partial_name, :at => [ width_of(label), top], :width => 100, :default => tbox_content)

          top = top + (font.height * 2)
          label = "Text Box 2: "
          draw_text(label, :at =>[left, top])
          draw_text_field(partial_name << "2", :at => [ width_of(label), top], :width => 100, :default => "Hey Joe") do |dict|
            dict[:MK] =  {:BC => [0,0.5,0]}
          end
          
        end
      end
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_form_draw_mult_text_field.pdf"
    end

    
  end # end context
end
