require 'test_helper'

class PrawnTextBoxTest < ActiveSupport::TestCase

  context "TTV::Form" do
    
    setup do
      @pdf =  create_pdf("Test Form Text Field")
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
      @pdf.render_file "#{Rails.root}/tmp/prawn_one_textbox.pdf"      
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
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_multi_textbox.pdf"
    end

  end
end
