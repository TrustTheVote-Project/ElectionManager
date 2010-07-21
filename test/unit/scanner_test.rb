require 'test_helper'
require 'ballots/default/ballot_config.rb'

class ScannerTest < ActiveSupport::TestCase
  context "Scanner creation" do
    setup do
      @scanner = TTV::Scanner.new
      # @election = Election.make
      # @precinct = Precinct.make
      @election = TTV::ImportExport.import(File.new( RAILS_ROOT + "/test/elections/contests_mix.xml"))
      @precinct = @election.district_set.precincts.first
      
      @c = ::DefaultBallot::BallotConfig.new('default', 'en', @election, @scanner, "missing")
      
      @pdf = create_pdf("Test Scanner")
      @c.setup(@pdf, @precinct)
      @renderer = ::AbstractBallot::Renderer.new(@election, @precinct, @c,'')
    end
    
    subject { @scanner}
    
    should "create" do
      assert subject
    end
    
    # align checkbox is just wierd magic/vodoo
    should "align checkbox " do
      HORIZ_PADDING = 6
      top_left, location = subject.align_checkbox(@pdf, [@pdf.bounds.left + HORIZ_PADDING, @pdf.bounds.top])
      # print_bounds @pdf.bounds
    end

    # TODO: doesn't seem to do anything??
    should "render grid" do
      subject.render_grid(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/scanner_render_grid.pdf")                
    end
    
    # render the four filled in rectangles on the edges of the ballot
    should "render ballot marks" do
      subject.render_ballot_marks(@pdf)
      @pdf.render_file("#{Rails.root}/tmp/scanner_render_ballot_marks.pdf")                
    end
    
    should "render header" do
#      header = DefaultBallot::FlowItem::Header.new("Hey Header",
      #    @scanner)
      header = DefaultBallot::FlowItem::Header.new("Hey Header", nil)
      flow_rect = AbstractBallot::Rect.create_bound_box(@pdf.bounds)
      
      columns = AbstractBallot::Columns.new(3, flow_rect)
      # puts "columns = #{columns.inspect}"
      # columns.column_rects.each do |column|
      #         header.draw(@c, column)        
      #       end

      
      @pdf.render_file "/tmp/scan_header.pdf"
    end
    
    should "render ballot_marks" do
      subject.set_checkbox(22,10,:left)
      subject.render_grid @pdf
      subject.render_ballot_marks @pdf
      
      @pdf.render_file "/tmp/scanner_render_grid.pdf"
    end

    #     should "render it all " do
    #       File.open "renderer.pdf", 'w' do |f|
    #         f.write(@renderer.render)
    #       end
    #     end
  end
end
