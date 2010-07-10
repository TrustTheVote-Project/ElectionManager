require 'test_helper'
require 'ballots/default/ballot_config.rb'
require "pdf/reader"

class ContinuationBoxTest < ActiveSupport::TestCase
  context "DefaultBallot::ContinuationBox" do
    setup do

      
      @e1 = Election.make
      @p1 = Precinct.make
      @scanner = TTV::Scanner.new
      @lang = 'en'
      @style = "default"
      
      @ballot_config = DefaultBallot::BallotConfig.new(@style, @lang, @e1, @scanner, "missing")

      @prawn_doc = create_pdf("Continuation Box Test")
      
      # TODO: ContinuationBox depends on a prawn document
      @c_box = DefaultBallot::ContinuationBox.new(@prawn_doc)
      @is_last_page = true
      @pdf_fname =  "#{Rails.root}/tmp/continuation_box_test.pdf"
      
      @good_text = "/DeviceRGB cs\n0.000 0.000 0.000 scn\n/DeviceRGB CS\n0.000 0.000 0.000 SCN\nq\n\nBT\n63.535 751.82 Td\n/F1.0 10 Tf\n[<5468616e6b2079> 25 <6f752066> 20 <6f722076> 30 <6f74696e672e>] TJ\nET\n\n\nBT\n54.385 739.92 Td\n/F1.0 10 Tf\n[<506c65617365207475726e20696e2079> 25 <6f75722062616c6c6f74>] TJ\nET\n\n0.75 w\n0.000 0.000 0.000 SCN\n18.000 732.200 m\n210.000 732.200 l\nS\n210.000 732.200 m\n210.000 762.000 l\nS\n18.000 732.200 m\n18.000 762.000 l\nS\nQ\nQ\n"

    end

    teardown do
      #FileUtils.rm @pdf_fname, :force => true
    end
    
    should "be created" do
      assert @c_box
    end

    # This is a 3 sided box with lines on each side and the bottom.
    should "draw a box with thanks and asking to turn in youre ballot" do
      flow_rect = AbstractBallot::Rect.create_bound_box(@prawn_doc.bounds)
      three_columns = AbstractBallot::Columns.new(3, flow_rect)
      
      @c_box.draw(@ballot_config, three_columns.next, @is_last_page )
      @prawn_doc.render_file(@pdf_fname)

      render_and_find_objects(@prawn_doc)
      
      assert_equal @good_text, @text.data
      assert_equal "Prawn", @producer
      assert_equal "TrustTheVote", @creator
      assert_equal "Continuation Box Test", @title
      # @outline_root.each do |x|
      #   puts "x = #{x.inspect}"
      # end
    end
  end # end "DefaultBallot::ContinuationBox" context
end
