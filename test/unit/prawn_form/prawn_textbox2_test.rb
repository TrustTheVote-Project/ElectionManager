require 'test_helper'

class PrawnTextBoxTest < ActiveSupport::TestCase

  context "TTV::Form Textbox" do
    context "A one page pdf form with three text fields" do
      setup do
        @pdf = create_pdf("Simple PDF")

        @pdf.form do
          
          bounding_box([100,600], :width => 400, :height => 200) do
            stroke_bounds

            label = "Text Field "
            # offset the text field from the left by the width of the label
            x_offset = width_of(label) + 3
            # height of the textbox is the height of the label text
            # seems to be too small?
            field_height = height_of(label)
            
            # create a label and text field
            text label
            draw_text_field("textfield 0", :at => [ x_offset, bounds.top - field_height], :width => 50, :height => field_height)
            
            # create a label and text field
            draw_text(label, :at =>[0, 50])
            draw_text_field("textfield 1", :at => [ x_offset, 50], :width => 50, :default => "TestField 1 Content")
            
            # create a label and ugly text field
            draw_text(label, :at =>[0, 100])
            draw_text_field("textfield 2", :at => [ x_offset, 100], :width => 50, :default => "TestField 2 Content") do |dict|
              # border color green
              dict[:MK] =  {:BC => [0,0.5,0]}
              # solid border 3 pts wide
              dict[:BS] =  {:Type => :Border, :W => 3, :S => :S}
            end
          end
        end
        
        # Used to parse the raw pdf output
        @reader = TTV::Prawn::Reader.new(@pdf)
      end

      should "have an acroform in the catalog" do
        acroform = @reader.catalog[:AcroForm] 
        # puts "TGD: acroform ref = #{acroform.inspect}"
        assert acroform
      end
      
      should "have an acroform that is a reference" do
        acroform = @reader.catalog[:AcroForm] 
        assert_equal PDF::Reader::Reference, acroform.class
      end
      
      should "have an acroform with 3 fields" do
        # NOTE: only one acroform and one fields list per document
        acroform = @reader.obj(@reader.catalog[:AcroForm] )
        #puts "TGD: acroform = #{acroform.inspect}"
        assert !acroform[:Fields].empty?
        assert_equal 3, acroform[:Fields].size
        # puts "TGD: acroform fields list = #{acroform[:Fields].inspect}"
        # puts "TGD: acroform fields = #{@reader.ref_to_str(acroform[:Fields])}"

        assert_equal '[8 0 R, 9 0 R, 10 0 R]', @reader.ref_to_str(acroform[:Fields])
      end            
      
      should "have 3 fields" do
        fields = @reader.fields
        # puts "TGD: fields = #{fields.inspect}"
        assert_equal 3, fields.length
      end

      should "have only fields that are widget annotations " do
        fields = @reader.fields
        fields.each do |field|
          assert_equal :Annot, field[:Type]
          assert_equal :Widget, field[:Subtype]
        end
      end
      
      should "have only fields that are text fields " do
        fields = @reader.fields
        fields.each do |field|
          assert_equal :Tx, field[:FT]
        end
      end
      
      should "have one page with all the annotation references/textfields" do
        # NOTE: page annotations will have ONLY that text fields that
        # fit on the page.
        annots = @reader.page(1)[:Annots]
        assert_equal PDF::Reader::Reference, annots.class
        
        annots = @reader.page_annotations(1)
        assert_equal 3, annots.length

        annots.each do |annot|
          assert_equal :Annot, annot[:Type]
          assert_equal :Widget, annot[:Subtype]
          assert_equal :Tx, annot[:FT]
        end

      end
      
      should "have the same set of objects referenced by fields and page annotations" do

        field_refs = @reader.obj(@reader.catalog[:AcroForm])[:Fields]
        #puts "TGD: field_refs = #{field_refs.inspect}"
        
        page_annotation_refs = @reader.obj(@reader.page(1)[:Annots])
        #puts "TGD: page_annotation_refs = #{page_annotation_refs.inspect}"

        assert_equal page_annotation_refs.length, field_refs.length
        
        page_annotation_refs.each do |annot_ref|
          assert field_refs.include? annot_ref
        end

        field_refs.each do |field_ref|
          assert page_annotation_refs.include? field_ref
        end
      end

      should "create a reader_textfields.pdf with 3 text fields" do
        
        @reader.render_file("#{Rails.root}/tmp/reader_textfields.pdf")

      end

    end
  end
end
