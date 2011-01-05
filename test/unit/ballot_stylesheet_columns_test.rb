# OSDV Election Manager - Unit Test for Ballot Style Sheet Column
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

class BallotStyleSheetColumnsTest < ActiveSupport::TestCase
  context "" do
    setup do
      create_election_with_precincts
      create_contests(3)
      create_questions(2)
      @template = BallotStyleTemplate.make(:display_name => "BallotStyleTemplate", :pdf_form => false)

      @template.load_style("#{Rails.root}/test/unit/data/newballotstylesheet/test_stylesheet.yml")
      @ballot_config = DcBallot::BallotConfig.new( @election, @template)
      @election.ballot_style_template_id = @template.id

    end
    
    should "render a ballot with 3 columns" do
      @ballot_config = ::DcBallot::BallotConfig.new( @election, @template)
      @renderer = AbstractBallot::Renderer.new(@election, @precinct_split, @ballot_config, nil)
      @renderer.render
      @pdf = @renderer.instance_variable_get(:@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_columns_three.pdf")
    end

    should "render a ballot with 4 columns" do
      @template.ballot_layout['columns'] = 4
      @election.ballot_style_template_id = @template.id
      @ballot_config = ::DcBallot::BallotConfig.new( @election, @template)
      @renderer = AbstractBallot::Renderer.new(@election, @precinct_split, @ballot_config, nil)

      @renderer.render
      @pdf = @renderer.instance_variable_get(:@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_columns_four.pdf")
    end
    
    should "render a ballot with 2 columns" do
      @template.ballot_layout['columns'] = 2
      @election.ballot_style_template_id = @template.id
      @ballot_config = ::DcBallot::BallotConfig.new( @election, @template)
      @renderer = AbstractBallot::Renderer.new(@election, @precinct_split, @ballot_config, nil)

      @renderer.render
      @pdf = @renderer.instance_variable_get(:@pdf)
      @pdf.render_file("#{Rails.root}/tmp/ballot_columns_two.pdf")
    end
    
  end
end
