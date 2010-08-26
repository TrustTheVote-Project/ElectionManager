require 'test_helper'

class PrawnRadioButtonTest < ActiveSupport::TestCase
  context "TTV::Form" do
    
    setup do
      @pdf =  create_pdf("Test Form Text Field")
    end
    
    should "be able to create a set of radioboxes" do
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
      @pdf.render_file "#{Rails.root}/tmp/prawn_radiobutton.pdf"
    end
    
  end
end
