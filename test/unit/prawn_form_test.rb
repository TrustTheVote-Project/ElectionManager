require 'test_helper'

class PrawnFormTest < ActiveSupport::TestCase

  context "TTV::Form" do

    setup do
      @pdf =  create_pdf("Test Form Text Field")
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
    
  end # end context
end
