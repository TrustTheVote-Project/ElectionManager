require 'test_helper'

class PrawnCheckboxTest < ActiveSupport::TestCase
  
  def draw_contest(pdf, left,top, width, text, options={})
    cb_width = 22
    cb_height = 10
    
    opts = { :top_margin => 0,
      :right_margin => 0,
      :bottom_right => 0,
      :left_margin => 0,
      :active => false,
      :cb_name => "cb" }.merge(options)
    
    # draw bounding box at top/left of enclosing rect/bounding box
    pdf.bounding_box([opts[:left_margin], opts[:top_margin]], :width => cb_width+3) do
      # draw_checkbox draws from lower right of it's bounding box
      # so translate bottom of checkbox to be near bounds.top
      if(opts[:active])
        cb_bottom = pdf.bounds.top-cb_height 
        pdf.draw_checkbox(opts[:cb_name], :at => [0, cb_bottom], :width => cb_width, :height => cb_height)
      else
        pdf.rectangle([0,0], cb_width, cb_height)
        @pdf.stroke
      end
    end

    # box for wrapping text
    # draw bounding box at top of bounding box.
    # and indented the width of checkbox.
    opts[:left_margin] = cb_width + 6
    pdf.bounding_box([opts[:left_margin], opts[:top_margin]], :width => width - cb_width - 6 ) do
      pdf.text(text)
    end
    
    contest_bottom = [pdf.bounds.top, cb_height].max # bottom of contest
  end
  

  context "TTV::Form" do
    
    setup do
      @pdf =  create_pdf("Test Form Text Field")
    end
    
    should "draw a contest box" do
      @pdf.form 
      # left, top, width, text
      left = 50; top = 600; width = 150
      contest_bottom = nil
      
      @pdf.bounding_box([left, top], :width => width) do
        contest_bottom = draw_contest(@pdf,0, 0, width, "Some very long name of a candidate for a contest\n Democratic Party")
      end
      assert_in_delta 55, contest_bottom, 1.0
      @pdf.render_file "#{Rails.root}/tmp/prawn_1_contest.pdf"
    end
    context "draw three" do

      setup do
        @pdf.form
        # absolute coordinates for enclosing rectangle/bounding box
        @left = 50; @top = 600; @width = 150;
      end
      
      should "contest boxes " do
        
        initial_top = @top
        contest_bottom = 0
        @pdf.bounding_box([@left, @top], :width => @width) do      
          
          ["Some very long name of a candidate for a contest\n Green Party",
           "George W. Bush\n Republican Party",
           "Barack Obama\n Democratic Party"
          ].each do |text|
            name = text[0..4]
            contest_bottom = draw_contest(@pdf, 0, contest_bottom, @width, text, :cb_name => name)
          end
        end
        
        contests_height = 490
        assert_in_delta initial_top - contests_height, contest_bottom, 1.0
        
        @pdf.render_file "#{Rails.root}/tmp/prawn_3_contests.pdf"
      end

      should "active contest boxes " do
        
        initial_top = @top
        contest_bottom = 0
        @pdf.bounding_box([@left, @top], :width => @width) do      
          
          ["Some very long name of a candidate for a contest\n Green Party",
           "George W. Bush\n Republican Party",
           "Barack Obama\n Democratic Party"
          ].each do |text|
            name = text[0..4]
            contest_bottom = draw_contest(@pdf, 0, contest_bottom, @width, text, :cb_name => name, :active => true)
          end
        end
        
        contests_height = 490
        assert_in_delta initial_top - contests_height, contest_bottom, 1.0
        
        @pdf.render_file "#{Rails.root}/tmp/prawn_3_active_contests.pdf"
      end
    end    

    #     should "draw a contest box old" do
    #       @pdf.form 
    #       # left, top, width, text
    #       left = 50; top = 600; width = 150

    #       contest_bottom = draw_contest_old(@pdf,left, top, width, "Some very long name of a candidate for a contest\n Democratic Party")
    #       assert_in_delta 55, contest_bottom, 1.0

    #       @pdf.render_file "#{Rails.root}/tmp/prawn_1_contest_old.pdf"
    #     end

    #     should "draw three contest boxes old " do
    #       @pdf.form 
    
    #       # absolute coordinates
    #       left = 50
    #       initial_top = top = 600
    #       width = 150
    
    #       ["Some very long name of a candidate for a contest\n Democratic Party",
    #        "George W. Bush\n Republican Party",
    #         "Barack Obama\n Democratic Party"
    #       ].each do |text|
    
    #         contest_bottom = draw_contest_old(@pdf,left, top, width, text)
    #         top -= contest_bottom
    #       end
    #       # shb decrease top by 111 pts
    #       assert_in_delta initial_top-111, top, 1.0
    
    #       @pdf.render_file "#{Rails.root}/tmp/prawn_3_contests_old.pdf"
    #   end
    
    #     should "draw a checkbox and text" do
    
    #       left = 50; top = 600
    #       w = 150; h = 300

    #       cb_width = 22
    #       cb_height = 10
    
    #       @pdf.form do
    #         puts "before all is checkbox is drawn"
    
    #         TTV::Prawn::Util.show_bounds_coordinates(bounds)

    #         # bounding box to contain both checkbox and text
    #         #bounding_box([left, top], :width => w, :height => 400) do
    #         #stroke_bounds
    #         bounding_box([left, top], :width => w) do
    
    #           puts "before checkbox is drawn"
    #           TTV::Prawn::Util.show_bounds_coordinates(bounds)

    #           # bounding box to contain active checkbox
    #           #bounding_box([0, bounds.top], :width => cb_width+3, :height => 300) do 
    #           #stroke_bounds
    #           bounding_box([0, bounds.top], :width => cb_width+3) do
    #             # adjust the origin, lower left, of the checkbox to be
    #             # at [0, (top of containing box - height of checkbox)]
    #             # needed cause draw_checkbox coor system is from lower
    #             # left upwards
    #             draw_checkbox("cb_name", :at => [0, bounds.top-cb_height], :width => cb_width, :height => cb_height)
    #           end
    
    #           puts "before text is drawn"
    #           TTV::Prawn::Util.show_bounds_coordinates(bounds)
    
    #           #bounding_box([cb_width + 6, bounds.top], :width => w - cb_width -6, :height => 300 ) do
    #           # stroke_bounds
    #           bounding_box([cb_width + 6, bounds.top], :width => w - cb_width -6) do
    #             text("Drawn by text 22222222222222222222222222222")          
    #           end
    
    #           puts "after text is drawn"
    #           TTV::Prawn::Util.show_bounds_coordinates(bounds)
    #         end

    #       end
    
    #       @pdf.render_file "#{Rails.root}/tmp/prawn_checkbox3.pdf"
    
    #     end

    #     should "show all the ways text can be drawn" do
    #       x = 100; y = 600; w = 100; h = 100
    #       partial_name = "Internal Checkbox Name"
    
    #       @pdf.form do
    #         label = "This is a long string of text for CheckBox 1: "        
    
    #         # create a box around the label and text field
    #         # box from [100, 600] (upper left point)
    #         # to [200, 500] ()lower right point)
    #         bounding_box([x,y], :width => w, :height => h) do
    
    #           # bounds is always, a 100 x 100 box
    #           # t, r, b, l = "100, 100, 0, 0"
    #           TTV::Prawn::Util.show_bounds_coordinates(bounds)
    
    #           stroke_bounds
    
    #           # draws a checkbox in the bottom left of the bounding box
    #           draw_checkbox(partial_name, :at => [0, 0], :width => 22, :height => 10)
    
    #           # draws text in the bottom left of the bounding box. text
    #           # will not wrap when it reaches the right side of the
    #           # bounding box. NOT good.
    #           draw_text("Drawn by draw_text 1111111111111111111111111111", :at =>[0, 0])

    #           # draws text from the upper left of the bounding box and
    #           # will wrap when it hits the right side of the bounding box.
    #           font "Helvetica", :size => 10
    #           text("Drawn by text 22222222222222222222222222222")
    
    #           # Doesn't draw within the bounding box!!
    #           # draw a rectangle below the bounding box. starting at lower
    #           # left of bounding box and down by 10 to right by 10
    #           stroke_rectangle([0,0], 10, 10)
    
    #           # Doesn't draw within the bounding box!!
    #           # draw text at bottom at bounding box. starting at lower
    #           # left 
    #           text_box("Drawn by text_box 333333333333333333333", :at => [0, 0], :width => 50, :height => 100)

    #         end
    
    #         #bounding_box([x+40,y], :width => 100) do
    #         # stroke_bounds
    #         #end
    
    #       end
    
    #       @pdf.render_file "#{Rails.root}/tmp/prawn_checkbox2.pdf"
    #     end

  end

  def draw_contest_old(pdf, left,top, width, text)
    cb_width = 22
    cb_height = 10
    
    # puts "TGD: before contest"
    # TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)    
    # TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)
    contest_box_bottom = nil
    
    w = width
    # box enclosing checkbox and flowing text
    pdf.bounding_box([left, top], :width => w) do
      #puts "TGD: before checkbox"
      #TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)  
      #TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)
      
      pdf.bounding_box([0, @pdf.bounds.top], :width => cb_width+3) do
        pdf.draw_checkbox("cb_name", :at => [0, @pdf.bounds.top-cb_height], :width => cb_width, :height => cb_height)
      end
      
      # box for wrapping text
      pdf.bounding_box([cb_width + 6, @pdf.bounds.top], :width => w - cb_width - 6 ) do
        pdf.text(text)
      end

      # the wrapping text, drawn with text(...)  above,  will increase
      # the top of this bounding box. Remember, text flows down towards
      # the bottom of this bounding box.

      # Before text is drawn:
      # Bounds coordinates "t, r, b, l" = "0.0, 150, 0, 0"
      # Absolute Bounds coordinates "t, r, b, l" = "80.0, 218, 80.0, 68"
      # After text is drawn:
      # Bounds coordinates "t, r, b, l" = "41.616, 150, 0, 0"
      # Absolute Bounds coordinates "t, r, b, l" = "80.0, 218, 38.384, 68"
      # puts "TGD: after text"
      # TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)      #
      # TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)      #
      #box for checkbox
      contest_box_bottom = [@pdf.bounds.top, cb_height].max

    end
    # puts "TGD: after contest"
    # TTV::Prawn::Util.show_bounds_coordinates(@pdf.bounds)    
    # @TTV::Prawn::Util.show_abs_bounds_coordinates(@pdf.bounds)
    contest_box_bottom
  end

end
