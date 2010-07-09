require 'test_helper'
require 'ballots/default/ballot_config.rb'


class PDFBallotStyleTest < ActiveSupport::TestCase
  context "PDFBallotStyle" do
    
    context "list method" do
      setup do
        # setup some dummy, mock directories for ballots
        # NOTE: The "default" ballot style is always returned,even if
        # there is NOT a directory
        @dummy_ballot_styles = %w{nh mass sunnyvale}    
        
        # Dir.expects(:open).with(PDFBallotStyle::BALLOT_DIR).at_least_once().returns(@dummy_ballot_styles)
        Dir.expects(:open).with(PDFBallotStyle::BALLOT_DIR).returns(@dummy_ballot_styles)

        # pretend each dummy ballot style is a directory
        @dummy_ballot_styles.each do |dir|
          File.expects(:directory?).with("#{PDFBallotStyle::BALLOT_DIR}/#{dir}").returns(true)
        end

      end  

      should "list all ballot styles" do
        # the default ballot style will always be listed.
        assert_equal ["default"] + @dummy_ballot_styles, PDFBallotStyle.list
      end

      should "always list the default ballot style" do
        assert_contains  PDFBallotStyle.list, "default"
      end  
    end # end list context
    
    context " get_file method" do
      setup do
        @dummy_ballot_style = "mass"
        @file_name = "description.html"
        IO.expects(:read).with("#{PDFBallotStyle::BALLOT_DIR}/#{@dummy_ballot_style}/#{@file_name}")
      end
      
      should "get a ballot style file " do
        PDFBallotStyle.get_file(@dummy_ballot_style,@file_name)
      end
    end # end get_file context

    # TODO: possibly remove this method as it only redirects to
    # creating and ElectionTranslation instance
    context "get_election_translation(...) method" do
      setup do
        @election = Election.make
        @lang = 'en'

        # election translation should load a YAML file for this
        # specific election
        # Need a mock/stub/expectation here cuz there is no real file of
        # this name in the app.
        YAML.expects(:load_file).with("#{Election::TRANSLATION_FOLDER}/election-#{@election.id}.#{@lang}.yml")
      end

      should "get an election translation object" do
        election_xlation = PDFBallotStyle.get_election_translation(@election, @lang)
      end
    end # end "get_election_translation(...) method" context

    context "get_ballot_translation method" do
      setup do
        @dummy_ballot_style = "mass"
        @lang = 'en'
        @backing_filename = "#{PDFBallotStyle::BALLOT_DIR}/#{@dummy_ballot_style}/lang/#{@lang}/ballot.yml"        
        # mock to get test to pass
        YAML.expects(:load_file).with(@backing_filename)
      end
      
      should "get a yaml translation object" do
        @yaml_xlation = PDFBallotStyle.get_ballot_translation(@dummy_ballot_style, @lang)

        file_name = @yaml_xlation.instance_variable_get(:@filename)
        assert_equal @backing_filename, file_name 
        
        assert_instance_of  TTV::Translate::YamlTranslation, @yaml_xlation
        assert_kind_of  TTV::Translate::YamlTranslation, @yaml_xlation
      end
    end # end "get_ballot_translation method" context

    context "get_ballot_config"do
      context "with a dummy ballot class" do
        # create a dummy ballot module that has a BallotConfig class
        module ::DummyBallot
          class BallotConfig
            attr_accessor :dummy
            def initialize(style, lang, election, scanner, instruction_text_url)
              @dummy = "got the dummy"
            end
          end
        end

        # get this dummy ballot class in the DummyBallot module
        setup do
          @style = "dummy"
          @ballot_config_class = PDFBallotStyle.get_ballot_config(@style, nil, nil, nil,nil)
        end

        should "have the correct BallotConfig class" do
          assert_instance_of ::DummyBallot::BallotConfig, @ballot_config_class
          assert_kind_of ::DummyBallot::BallotConfig, @ballot_config_class
        end
        
      end # "with a dummy ballot class" context
      
      context "with the default ballot class" do
        setup do
          @style = "default"
          
          # mock scanner set_checkbox method just to get the test to pass
          scanner = TTV::Scanner.new
          scanner.expects(:set_checkbox)
          
          @ballot_config_class = PDFBallotStyle.get_ballot_config(@style, "en", Election.make, scanner, nil)
        end
        
        should "have the correct DefaultBallot::BallotConfig class" do
          assert_instance_of ::DefaultBallot::BallotConfig, @ballot_config_class
          assert_kind_of ::DefaultBallot::BallotConfig, @ballot_config_class
        end
      end
      
    end # end "get_ballot_config" context
    
  end # end PDFBallotStyle context
end
