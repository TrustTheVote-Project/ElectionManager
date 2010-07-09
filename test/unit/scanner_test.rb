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
      
      @pdf = Prawn::Document.new(
                                 :page_layout => :portrait,
                                 :page_size => "LETTER",
                                 :left_margin => 18,
                                 :right_margin => 18,
                                 :top_margin => 30,
                                 :bottom_margin => 30,
                                 # :skip_page_creation => true,
                                 :info => { :Creator => "TrustTheVote",
                                   :Title => "Test Scanner"
                                 }
                                 )
      @c.setup(@pdf, @precinct)
      @renderer = ::AbstractBallot::Renderer.new(@election, @precinct, @c,'')
    end
    
    subject { @scanner}
    
    should "dfo" do
      assert subject
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

      
      @pdf.render_file "header.pdf"
    end
    
    should "render grid" do
      subject.set_checkbox(22,10,:left)
      subject.render_grid @pdf
      subject.render_ballot_marks @pdf
      
      @pdf.render_file "scanner_render_grid.pdf"
    end

    #     should "render it all " do
    #       File.open "renderer.pdf", 'w' do |f|
    #         f.write(@renderer.render)
    #       end
    #     end
  end
end
