require 'test_helper'

class PrawnTextBoxTest < ActiveSupport::TestCase

  context "TTV::Form and Prawn transactions" do
    context "rollback with no existing form fields" do
      setup do
        
        @pdf = create_pdf("Simple Form PDF")
        
        @pdf.form
        @pdf.transaction do
          
          @pdf.bounding_box([100,600], :width => 400, :height => 200) do
            @pdf.stroke_bounds
            
            label = "Text Field "
            # offset the text field from the left by the width of the label
            x_offset = @pdf.width_of(label) + 3
            # height of the textbox is the height of the label text
            # seems to be too small?
            field_height = @pdf.height_of(label)
            
            # create a label and text field
            @pdf.text label
            @pdf.draw_text_field("textfield 0", :at => [ x_offset, @pdf.bounds.top - field_height], :width => 50, :height => field_height)
            
            @pdf.rollback
          end # end bounding_box
        end # end xaction
        
        @reader = TTV::Prawn::Reader.new(@pdf)
      end # end setup
      
      should "be a form" do
        assert @reader.form?
      end
      
      should "not have fields" do
        #puts "TGD: @reader_after = #{@reader_after.pdf_contents.inspect}"
        assert @reader.fields.empty?
      end
      
      should "not have annotations/textfields on the first page" do
        assert !@reader.page_annotations(1)
      end
      
    end # end context rollback with no existing form fields 
    
    context "rollback with one existing form fields" do
      setup do
        @pdf = create_pdf("Simple Form PDF")
        @pdf.form
        @pdf.bounding_box([100,600], :width => 400, :height => 200) do        
          
          @pdf.draw_text_field("textfield 0", :at => [ 0, 100], :width => 50, :height => 20)
          
          # This text fields shouldn't be seen
          @pdf.transaction do
            @pdf.draw_text_field("textfield 2", :at => [ 0, 200], :width => 50, :height => 20)
            @pdf.rollback
          end # end xaction
          
        end
        @reader = TTV::Prawn::Reader.new(@pdf)
      end # end setup
      
      should "be a form" do
        assert @reader.form?
      end
      
      should "not only have 1 field" do
        # puts "TGD: @reader.fields = #{@reader.fields.inspect}"
        assert_equal 1,  @reader.fields.length
      end
      
      should "have only one annotation/textfield on the first page" do
        assert_equal 1,  @reader.page_annotations(1).length
        @reader.render_file("#{Rails.root}/tmp/prawn_xaction_one_txtfield.pdf")
      end
      
    end # end context
    
    context "rollback with many existing form fields" do
      setup do
        @pdf = create_pdf("Simple Form PDF")
        @pdf.form
        @pdf.bounding_box([100,600], :width => 400, :height => 200) do        

          @field_count = 12
          
          @field_count.times do
            @pdf.draw_text_field("textfield 0", :at => [ 0, 100], :width => 50, :height => 20)
          end
          # This text fields shouldn't be seen
          @pdf.transaction do
            @pdf.draw_text_field("textfield 2", :at => [ 0, 200], :width => 50, :height => 20)
            @pdf.rollback
          end # end xaction
          
        end
        @reader = TTV::Prawn::Reader.new(@pdf)
      end # end setup
      
      should "be a form" do
        assert @reader.form?
      end
      
      should "have many fields" do
        #puts "TGD: @reader.fields = #{@reader.fields.inspect}"
        assert_equal @field_count,  @reader.fields.length
      end
      
      should "have many annotations/textfields " do
        assert_equal @field_count,  @reader.page_annotations(1).length
        @reader.render_file("#{Rails.root}/tmp/prawn_xaction_many_txtfields.pdf")
      end
      
    end # end context
  end
end

