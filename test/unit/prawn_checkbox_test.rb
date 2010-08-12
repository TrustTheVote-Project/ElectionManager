require 'test_helper'

class PrawnCheckboxTest < ActiveSupport::TestCase

  context "TTV::Form" do
    
    setup do
      @pdf =  create_pdf("Test Form Text Field")
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
      
      @pdf.render_file "#{Rails.root}/tmp/prawn_checkbox.pdf"
    end

  end
end
