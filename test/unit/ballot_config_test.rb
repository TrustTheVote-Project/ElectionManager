require 'test_helper'
require 'ballots/default/ballot_config.rb'


class BallotConfigTest < ActiveSupport::TestCase
  setup_jurisdictions do  
    
    context "Default::BallotConfig" do
      context "initialize " do
        setup do
          @e1 = Election.find_by_display_name "Election 1"
          @p1 = Precinct.find_by_display_name "Precint 1"
          @scanner = TTV::Scanner.new
          @lang = 'en'
          @style = "default"

          @ballot_config = DefaultBallot::BallotConfig.new(@style, @lang, @e1, @scanner, "missing")

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
          
          @ballot_config.setup(@pdf, @p1)          
        end # end setup
        
        should "set the correct ballot directory " do
          assert_equal  "#{Rails.root}/app/ballots/#{@style}", @ballot_config.instance_variable_get(:@file_root) 
        end
        
        should "set the correct ballot translation" do
          assert_instance_of TTV::Translate::YamlTranslation, @ballot_config.instance_variable_get(:@ballot_translation)           
        end
        
        should "set the correct election translation" do
          assert_instance_of TTV::Translate::ElectionTranslation, @ballot_config.instance_variable_get(:@election_translation)           
        end
        
        should "create a ballot config " do
          assert @ballot_config
        end

        #TODO: load_test method doesn't seem to be used anywhere
        should "load the ballot file for the language code #{@lang}" do
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
        
        should "get a ballot translation" do
          assert_instance_of TTV::Translate::YamlTranslation, @ballot_config.ballot_translation
          assert_instance_of TTV::Translate::YamlTranslation, @ballot_config.bt           
        end

        should "get a election translation" do
          assert_instance_of TTV::Translate::ElectionTranslation, @ballot_config.election_translation
          assert_instance_of TTV::Translate::ElectionTranslation, @ballot_config.et
        end

        should "create a continuation box" do
          assert_instance_of DefaultBallot::ContinuationBox, @ballot_config.create_continuation_box
        end
        
      end # end initialize context
    end # end Default::BallotConfig context
    
  end # end setup_jurisdictions
end
