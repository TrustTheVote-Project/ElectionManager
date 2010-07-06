require 'test_helper'
require 'ttv/translate'

# TODO: prob doesn't need the ActiveSupport::TestCase
# no Rails functionality in the class under test
class ElectionTranslationTest < ActiveSupport::TestCase
  
  context "TTV::Translate::ElectionTranslation" do
    context "english language, the default, " do
      
      setup do
        # Allows one to save off key-value pairs for a specific election
        # and language. 
        # TODO: Rename class to ElectionAnnotate?
        
        # This will save key value pairs to YAML file named
        # /db/translations/election-<election id>.<language>.yml
        @election = Election.make
        @lang = 'en'
        @et = TTV::Translate::ElectionTranslation.new(@election, @lang)
        
        # remove the yaml file for this election
        # FileUtils.rm "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml", :force => true
        
      end
      
      should "be created " do
        assert @et
      end
      
      should "given an object and a method save it's value" do

        # string".size
        # object = "Some random string", method = size, value = 18. 

        # setting the property also returns the result of calling the
        # obj's method
        assert_equal @et.get("Some random string", 'size'), "Some random string".size

        # get the property
        assert_equal @et.get("Some random string", 'size'), "Some random string".size
        
        # should not be dirty
        assert !@et.dirty?
      end

      should "given a random object and a method persist it's value" do
        # set the property, returns the result of calling "Some random string".size
        assert_equal @et.get(:SomeRandomSymbol, 'to_i'), :SomeRandomSymbol.to_i
        
        assert_nothing_raised do
          @et.save
        end
        
        file_name = @et.instance_variable_get(:@filename)
        assert_equal file_name, "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml"
      end

      should "given a random object and a method retrieve it's value" do
        # OK, this is impossible to test.
        assert_equal @et.get(:SomeRandomSymbol, 'to_i'), :SomeRandomSymbol.to_i
      end
    end
    
    context "spanish language" do
      setup do
        # Allows one to save off key-value pairs for a specific election
        # and language. 
        # TODO: Rename class to ElectionAnnotate?
        
        # This will save key value pairs to YAML file named
        # /db/translations/election-<election id>.<language>.yml
        @election = Election.make
        @lang = 'es'
        @et = TTV::Translate::ElectionTranslation.new(@election, @lang)

        # remove the yaml file for this election
        FileUtils.rm "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml", :force => true
      end
      
      should "be created " do
        assert @et
      end
      
      should "given a random object and a method warn that it needs transaltion" do
        # set the property, returns the result of calling "Some random string".size
        #assert_not_equal @et.get(:SomeRandomSymbol, 'to_i'), :SomeRandomSymbol.to_i
        assert_equal @et.get(:SomeRandomSymbol, 'to_i'), 'NEEDSTRANSLATION'
        assert @et.dirty?
        
        assert_nothing_raised do
          @et.save
        end
        
        file_name = @et.instance_variable_get(:@filename)
        assert_equal file_name, "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml"
      end
      
    end
    
  end
end
