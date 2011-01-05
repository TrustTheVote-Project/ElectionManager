# OSDV Election Manager - Unit Test
# Author: Pito Salas
# Date: 10/5/2010
#
# License Version: OSDV Public License 1.2
#
# The contents of this file are subject to the OSDV Public License
# Version 1.2 (the "License"); you may not use this file except in
# compliance with the License. You may obtain a copy of the License at
# http://www.osdv.org/license/
# Software distributed under the License is distributed on an "AS IS"
# basis, WITHOUT WARRANTY OF ANY KIND, either express or implied. See the
# License for the specific language governing rights and limitations
# under the License.

# The Original Code is: TTV Election Manager and Ballot Design Studio.
# The Initial Developer of the Original Code is Open Source Digital Voting Foundation.
# Portions created by Open Source Digital Voting Foundation are Copyright (C) 2010.
# All Rights Reserved.

# Contributors: Aleks Totic, Pito Salas, Tom Dyer, Jeffrey Gray, Brian Jordan, John Sebes.
require File.dirname(__FILE__) + '/../test_helper'

class RendererTest < ActiveSupport::TestCase
  
  context "AbstractBallot::Renderer with pdf form elements" do
    
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
      ["Lt Governor", "State Rep", "Attorney General","Governor", "Contest5", "Contest6", "Contest7"].each do |contest_name|
        create_contest(contest_name,  VotingMethod::WINNER_TAKE_ALL,e1.district_set.jur_districts.first, e1, pos)
        pos += 1
      end
      
      contest = Contest.make(:display_name => "ContestNotFitOnPage",
                             :voting_method => VotingMethod::WINNER_TAKE_ALL,
                             :district => e1.district_set.jur_districts.first,
                             :election => e1, :position => pos, :ident => "ident-ContestNoFitOnPage")
      
      pos += 1
      
      # create a set of checkboxes that will not fit on page 1.
      [:silly, :bluehat, :redshirt, :socialdemocrat, :nonothing, :whig, :bongo, :communist, :green, :democrat, :republican, :independent].each do |party_sym|
        party = Party.make(:display_name => party_sym.to_s)
        Candidate.make(:party => party, :display_name => "#{party_sym}_Candidate", :contest => contest, :ident => "ident-#{party_sym}_Candidate_#{contest.display_name}")
      end
      
      Question.make(:display_name => "Dog Racing",
                    :election => e1,
                    :requesting_district => e1.district_set.districts.first,
                    :question => 'This proposed law would prohibit any dog racing or racing meeting in Massachusetts where any form of betting or wagering on the speed or ability of dogs occurs. The State Racing Commission would be prohibited from accepting or approving any application or request for racing dates for dog racing. Any person violating the proposed law could be required to pay a civil penalty of not less than $20,000 to the Commission. The penalty would be used for the Commission\'s administrative purposes, subject to appropriation by the state Legislature. All existing parts of the chapter of the state\'s General Laws concerning dog and horse racing meetings would be interpreted as if they did not refer to dogs. These changes would take effect January 1, 2010. The proposed law states that if any of its parts were declared invalid, the other parts would stay in effect.' )
      
      scanner = TTV::Scanner.new
      
      # This will create a pdf form
      @template = BallotStyleTemplate.make(:display_name => "test template", :pdf_form=> true)
      @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/test_stylesheet.yml")
      e1.ballot_style_template_id = @template.id
      
      @ballot_config = DefaultBallot::BallotConfig.new( e1, @template)

      @pdf = create_pdf("Test Renderer")
      @ballot_config.setup(@pdf, p1)

      destination = nil
      
      @renderer = AbstractBallot::Renderer.new(e1, @prec_split1, @ballot_config, destination)
      
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

end 
