require 'test_helper'
require 'ballots/default/ballot_config.rb'


class BallotConfig < ActiveSupport::TestCase
  setup_jurisdictions do  
    
    context "Default::BallotConfig" do
      setup do
        e1 = Election.find_by_display_name "Election 1"
        p1 = Precinct.find_by_display_name "Precint 1"
        scanner = TTV::Scanner.new
        @lang = 'en'
        @ballot_config = DefaultBallot::BallotConfig.new('default', @lang, e1, scanner, "missing")

        pdf = Prawn::Document.new(
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
        
        @ballot_config.setup(pdf, p1)
        
      end # end setup
      
      should "create a ballot config " do
        assert @ballot_config
      end
      
      # TODO: remove as it doesn't seem to be used?
      should "load the ballot file for the language code #{@lang}" do
        # load_text doesn't seem to be used anywhere?
        
        assert_nothing_raised do
          @ballot_config.load_text("ballot.yml")
        end
        assert_raise Errno::ENOENT do
          @ballot_config.load_text("fubar.yml")
        end
      end
      
      # TODO: remove as it doesn't seem to be used?      
      should "load the image for language code #{@lang}" do
        assert_nothing_raised do
          @ballot_config.load_image("instructions2.png")          
        end
      end

      should "get the ballot translation" do
        assert @ballot_config.ballot_translation
      end
    end # end Default::BallotConfig context
    
  end # end setup_jurisdictions
end
