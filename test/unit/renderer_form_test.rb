require 'test_helper'
require 'ballots/default/ballot_config.rb'

class RendererTest < ActiveSupport::TestCase
  
  context "AbstractBallot::Renderer " do
    
    setup do
      
      # create a precint within 4 Districts
      p1 = Precinct.create!(:display_name => "Precint 1")
      (0..3).each do |i|
        p1.districts << District.new(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
      end
      p1.save
      
      # create a jurisdiction with only the first 2 districts 
      ds1  = DistrictSet.create!(:display_name => "District Set 1")
      ds1.districts << District.find_by_display_name("District 0")
      ds1.districts << District.find_by_display_name("District 1")
      ds1.save!

      # make an election for this jurisdiction
      e1 = Election.create!(:display_name => "Election 1", :district_set => ds1)
      e1.start_date = DateTime.new(2009, 11,3)

      # OK, now we have a precinct that contains districts 0 to 3
      # And an election that has districts 0 and 1
      
      # Create 3 contests for this election
      pos = 0;
      ["State Rep", "Attorney General","Governor"].each do |contest_name|
        contest = Contest.make(:display_name => contest_name,
                               :voting_method => VotingMethod::WINNER_TAKE_ALL,
                               :district => e1.district_set.districts.first,
                               :election => e1, :position => pos)
        pos += 1
        [:democrat, :republican, :independent].each do |party_sym|
          party = Party.make(party_sym)
          Candidate.make(:party => party, :display_name => "#{party_sym}_Candidate", :contest => contest)
        end
      end
      
#       Question.make(:display_name => "Dog Racing",
#                     :election => e1,
#                     :requesting_district => e1.district_set.districts.first,
#                     :question => 'This proposed law would prohibit any dog racing or racing meeting in Massachusetts where any form of betting or wagering on the speed or ability of dogs occurs. The State Racing Commission would be prohibited from accepting or approving any application or request for racing dates for dog racing. Any person violating the proposed law could be required to pay a civil penalty of not less than $20,000 to the Commission. The penalty would be used for the Commission\'s administrative purposes, subject to appropriation by the state Legislature. All existing parts of the chapter of the state\'s General Laws concerning dog and horse racing meetings would be interpreted as if they did not refer to dogs. These changes would take effect January 1, 2010. The proposed law states that if any of its parts were declared invalid, the other parts would stay in effect.' )
      
      scanner = TTV::Scanner.new
      @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form=> true)
      @ballot_config = DefaultBallot::BallotConfig.new( e1, @template)

      @pdf = create_pdf("Test Renderer")
      @ballot_config.setup(@pdf, p1)

      destination = nil
      
      @renderer = AbstractBallot::Renderer.new(e1, p1, @ballot_config, destination)
      
      
    end
    
    should "should be created " do
      assert @renderer
    end

    # render the page including all the Contest flow objects in the
    # middle column. Same as above but don't need setup.
    should "render" do
      @renderer.render

      # get the pdf from the renderer this time
      # cuz this method creates it.
      # all the above methods assumed this render method was already
      # invoked
      pdf = @renderer.instance_variable_get(:@pdf)
      
      pdf.render_file("#{Rails.root}/tmp/renderer_render_form.pdf")                  

    end
  end # end AbstractBallot::Renderer context

  def check_rect(rect, delta, w, h, top, left, bottom, right)
    assert_equal  w, rect.width
    assert_in_delta  h, rect.height, delta
    
    assert_in_delta  top, rect.top, delta
    assert_equal  left, rect.left
    assert_equal  bottom, rect.bottom
    assert_in_delta  right, rect.right, delta
    
    true
  end
  
  def draw_rect(pdf, rect, color='ff0000')
    pdf.stroke_color(color) #"FFFFFF"
    pdf.stroke_line([rect.left, rect.top], [rect.right, rect.top])
    pdf.stroke_line([rect.left, rect.top], [rect.left, rect.bottom])
    pdf.stroke_line([rect.left, rect.bottom], [rect.right, rect.bottom])
    pdf.stroke_line([rect.right, rect.bottom], [rect.right, rect.top])
    
    # pdf.rectangle([rect.left, rect.top], rect.width, rect.height)
  end
end 
