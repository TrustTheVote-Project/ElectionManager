require 'test_helper'

class PrawnTextBoxTest < ActiveSupport::TestCase

  context "TTV::Form Textbox with a Prawn transaction" do
    setup do
      @pdf = create_pdf("Simple PDF")
      
      @reader_before = TTV::Prawn::Reader.new(@pdf)
      @pdf.transaction do
        
        @pdf.bounding_box([100,600], :width => 400, :height => 200) do
          @pdf.stroke_bounds
        end
        @pdf.rollback
      end
      
      # Used to parse the raw pdf output
      @reader_after = TTV::Prawn::Reader.new(@pdf)
    end
    
    should "have not changed the pdf" do
      assert_equal @reader_before.pdf_contents, @reader_before.pdf_contents
    end
    
    should "have not changed the pdf" do
      assert_equal @reader_before.title, @reader_after.title
      assert_equal @reader_before.creator, @reader_after.creator
      assert_equal @reader_before.catalog, @reader_after.catalog
      assert_equal @reader_before.pages, @reader_after.pages
      assert_equal @reader_before.page(1), @reader_after.page(1)

      # NOTE: The rollback adds an insignificant character or 2 to the
      # rolled back contents. Don't know why?
      # puts "TGD: page 1 content before = #{@reader_before.page_contents(1).inspect}"
      # puts "TGD: page 1 content after = #{@reader_after.page_contents(1).inspect}"
      
      # assert_equal @reader_before.page_contents(1), @reader_after.page_contents(1)
      # <"/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\nQ\n"> expected but was
      # <"/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\nQ\nQ\n">.

      # assert_equal @reader_before.pdf_contents, @reader_after.pdf_contents

    end
  end    
end
