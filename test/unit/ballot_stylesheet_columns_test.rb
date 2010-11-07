require 'test_helper'
require 'ballots/dc/ballot_config'

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
