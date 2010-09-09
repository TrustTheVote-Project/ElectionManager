require 'test_helper'
require 'ballots/dc/ballot_config.rb'

class RendererTest < ActiveSupport::TestCase
  
  context "AbstractBallot::Renderer " do
    
    setup do
      
      d1 = District.make(:display_name => "District 1", :district_type => DistrictType::COUNTY)
      d2 = District.make(:display_name => "District 2", :district_type => DistrictType::COUNTY)

      # create a jurisdiction with only the first 2 districts 
      ds1  = DistrictSet.make(:display_name => "District Set 1")
      ds1.districts << d1
      ds1.districts << d2
      ds1.jur_districts << d1
      
      p1 = Precinct.make(:display_name => "Precinct 1", :jurisdiction => ds1)
      # TODO: what happens when a precinct p1 has a different
      # jurisdiction/district_set that one of it's precincts?
      @prec_split1 = PrecinctSplit.make(:display_name => "Precinct Split 1", :precinct => p1, :district_set => ds1)
      p1.precinct_splits << @prec_split1

      # make an election for this jurisdiction
      e1 = Election.create!(:display_name => "Election 1", :district_set => ds1)
      e1.start_date = DateTime.new(2009, 11,3)

      # Create 3 contests for this election
      pos = 0;
      ["Contest 1", "Contest 2", "Contest 3", "State Rep", "Attorney General","Governor"].each do |contest_name|
        contest = create_contest(contest_name,
                                 VotingMethod::WINNER_TAKE_ALL,
                                 e1.district_set.jur_districts.first,
                                 e1, pos)
        pos += 1
      end
      
      Question.make(:display_name => "Dog Racing",
                    :election => e1,
                    :requesting_district => e1.district_set.districts.first,
                    :question => 'This proposed law would prohibit any dog racing or racing meeting in Massachusetts where any form of betting or wagering on the speed or ability of dogs occurs. The State Racing Commission would be prohibited from accepting or approving any application or request for racing dates for dog racing. Any person violating the proposed law could be required to pay a civil penalty of not less than $20,000 to the Commission. The penalty would be used for the Commission\'s administrative purposes, subject to appropriation by the state Legislature. All existing parts of the chapter of the state\'s General Laws concerning dog and horse racing meetings would be interpreted as if they did not refer to dogs. These changes would take effect January 1, 2010. The proposed law states that if any of its parts were declared invalid, the other parts would stay in effect.' )
      
      scanner = TTV::Scanner.new
      @template = BallotStyleTemplate.make(:display_name => "test template")
      #@template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form => true)
      
      # @template.page = ballot_page
      # @template.frame = ballot_frame
      # @template.contents = ballot_contents
      
      @ballot_config = ::DcBallot::BallotConfig.new( e1, @template)

      @pdf = create_pdf("Test Renderer")
      @ballot_config.setup(@pdf, p1)
      

      destination = nil
      
      # @renderer = AbstractBallot::Renderer.new(e1, p1, @ballot_config, destination)
      @renderer = AbstractBallot::Renderer.new(e1, @prec_split1, @ballot_config, destination)
      
    end
    
    should "should be created " do
      assert @renderer
    end

    # This will look for all the Contests and Questions for this
    # Precinct and create Contest, Question and Container Flow objects
    # for each.
    should "initialize all the flow items" do
      @renderer.init_flow_items
      
      flow_items = @renderer.instance_variable_get(:@flow_items)
      
      # Should have 7 flow items
      # A Combo flow that contains a Header flow and a Contest flow
      # 6 Contest flows
      # And a Question flow
      assert_equal 7, flow_items.size

      # First is a Combo Flow
      combo_flow = flow_items.first
      assert_instance_of DefaultBallot::FlowItem::Combo, combo_flow
      # This Combo Flow contains 2 other flow items
      combo_flow_items = combo_flow.instance_variable_get(:@flow_items)
      assert_equal 2, combo_flow_items.size
      # A Header Flow
      assert_instance_of DefaultBallot::FlowItem::Header, combo_flow_items.first
      # And a Contest Flow with a ref to the State Rep Contest
      contest_flow = combo_flow_items.last
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 1'), contest
      
      # Next is a Contest flow with a ref to the Attorney General Contest
      contest_flow = flow_items[1]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 2'), contest

      # A Contest flow with a ref to the Governor Contest
      contest_flow = flow_items[2]
      assert_instance_of DefaultBallot::FlowItem::Contest, contest_flow
      contest = contest_flow.instance_variable_get(:@item)
      assert_equal Contest.find_by_display_name('Contest 3'), contest

      # A Question flow
      #       question_flow = flow_items.last
      #       assert_instance_of DefaultBallot::FlowItem::Question, question_flow
      #       question = question_flow.instance_variable_get(:@item)
      #       assert_equal Question.find_by_display_name('Dog Racing'), question

    end

    #     # render the page including all the Contest flow objects in the
    #     # middle column
    #     should "render everything" do
    #       # setup 
    #       @renderer.init_flow_items
    #       pdf = @ballot_config.instance_variable_get(:@pdf)
    #       @renderer.instance_variable_set(:@pdf, pdf)

    
    #       @renderer.render_everything
    
    #       # TODO: find out why 2 pages are generated here. Should only
    #       # have one?
    #       pdf.render_file("#{Rails.root}/tmp/dc_render_everything.pdf")                  
    #       util = TTV::Prawn::Util.new(pdf)
    #     end

    # render the page including all the Contest flow objects in the
    # middle column. Same as above but don't need setup.
    should "render" do
      @renderer.render

      # get the pdf from the renderer this time
      # cuz this method creates it.
      # all the above methods assumed this render method was already
      # invoked
      pdf = @renderer.instance_variable_get(:@pdf)
      
      pdf.render_file("#{Rails.root}/tmp/dc_render.pdf")                  
      util = TTV::Prawn::Util.new(pdf)

      # first page is the contests

      # second page is the question 

    end
  end # end AbstractBallot::Renderer context
end 