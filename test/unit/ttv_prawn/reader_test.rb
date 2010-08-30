require 'test_helper'

class ReaderTest < ActiveSupport::TestCase
  
  context "A simple one page pdf" do
    setup do
      pdf = create_pdf("Simple PDF")
      @reader = TTV::Prawn::Reader.new(pdf)
    end
    
    should "have a hash representing the PDF" do
      assert @reader.hash
    end
    
    should "have a catalog" do
      catalog = @reader.catalog
      assert catalog
      # puts "TGD: catalog = #{catalog.inspect}"
      assert :Catalog, catalog[:Type]
      assert catalog[:Pages]
    end

    should "have a form" do
      assert !@reader.catalog[:AcroForm] 
    end
    
    should "have a reference for pages" do
      pages_ref = @reader.pages_ref
      # puts "TGD: pages_ref #{pages_ref.inspect}"
      
      assert_equal "2 0 R", pages_ref
    end
    
    should "have a pages object" do
      pages = @reader.pages
      # puts "TGD: pages #{pages.inspect}"
      assert_equal :Pages, pages[:Type]
    end

    should "have only one page" do
      pages = @reader.pages
      assert_equal 1, pages[:Count]
      assert_equal 1, pages[:Kids].length
      assert pages[:Count], pages[:Kids].length
    end

    should "have a page that is a page type" do
      page = @reader.page(1)
      # puts "TGD: page one =  #{page.inspect}"
      assert_equal :Page, page[:Type]
    end
    
    should "have a page that has contents" do
      page = @reader.page(1)
      assert_equal PDF::Reader::Reference, page[:Contents].class
    end
    
    should "have a page that does not have annotations" do
      page = @reader.page(1)
      assert !page[:Annots]
    end

    should "have a page that has a parent reference" do
      page = @reader.page(1)
      assert_equal @reader.catalog[:Pages], page[:Parent]
      assert_equal @reader.catalog[:Pages].id, page[:Parent].id
      assert_equal "2 0 R", @reader.ref_to_str(page[:Parent])
    end
    
    should "have a page that has resources" do
      page = @reader.page(1)
      assert page[:Resources]
    end
    
  end
end
