# -*- coding: utf-8 -*-
require 'test_helper'

class PrawnTextBoxTest < ActiveSupport::TestCase

  context "Textbox without a Prawn transaction" do
    setup do
      @pdf = create_pdf("Simple PDF")
        
      @pdf.bounding_box([100,600], :width => 400, :height => 50) do
        @pdf.stroke_bounds
        @pdf.text 'The single assertion per test style has a lot of nice features, but it can be kind of verbose, since each single-line test needs its own descrip- tion string. In this section, we examine two different tools for writing more concise one-assertion tests. One tool, Zebra, works nicely within Shoulda, while the other, Testbed, is more of a standalone tool. Again, the following chapter discusses RSpec’s own mechanisms for single line tests.'
      end
    end
    
    should "overflow the bounding box" do
      @pdf.render_file "#{Rails.root}/tmp/overflow_no_xaction.pdf"
    end
  end    
  
  context "Textbox with a Prawn transaction" do
    setup do
      @pdf = create_pdf("Simple PDF")
      
      @pdf.bounding_box([100,100], :width => 400, :height => 50) do
        @pdf.text "hey you "
      end
      
       @pdf.transaction do
        
        @pdf.bounding_box([100,600], :width => 400, :height => 50) do
          @pdf.text 'The single assertion per test style has a lot of nice features, but it can be kind of verbose, since each single-line test needs its own descrip- tion string. In this section, we examine two different tools for writing more concise one-assertion tests. One tool, Zebra, works nicely within Shoulda, while the other, Testbed, is more of a standalone tool. Again, the following chapter discusses RSpec’s own mechanisms for single line tests.'
        end
        @pdf.rollback
      end
      
    end
    should "overflow the bounding box" do
      @pdf.render_file "#{Rails.root}/tmp/overflow_with_xaction.pdf"
    end
  end
end

