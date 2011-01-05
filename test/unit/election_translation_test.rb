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

class ElectionTranslationTest < ActiveSupport::TestCase
  
  context "TTV::Translate::ElectionTranslation" do
    context "english language, the default, " do
      
      setup do
        # Allows one to save off key-value pairs for a specific election
        # and language in a YAML file that acts as a backing store for
        # this election 
        # TODO: Rename class to ElectionStore?
        
        # File name of this backing store will be:
        # /db/translations/election-<election id>.<language>.yml
        
        @election = Election.make
        @lang = 'en'
        @et = TTV::Translate::ElectionTranslation.new(@election, @lang)
        
        # may want to set an expectation in the future?
        # Avoid file access for this test?
        # YAML.expects(:load_file).with("#{Election::TRANSLATION_FOLDER}/election-#{@election.id}.#{@lang}.yml").returns({"some_key" => "some_value"})
        
      end
      
      teardown do
        # get rid of the YAML file that is the store for this election
        FileUtils.rm "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml", :force => true
      end
      
      should "be created " do
        assert @et
        assert_instance_of  TTV::Translate::ElectionTranslation, @et
        assert_kind_of  TTV::Translate::ElectionTranslation, @et
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
      
      should "only create a backing store if the save method was invoked" do
        assert_equal @et.get("Some random string", 'size'), "Some random string".size

        # no YAML file for backing store shd exist
        assert_raise Errno::ENOENT do
          YAML.load_file("#{Election::TRANSLATION_FOLDER}/election-#{@election.id}.#{@lang}.yml")
        end
      end

      should "given a random object and a method persist it's value" do
        
        # set the property, returns the result of calling "Some random string".size
        assert_equal @et.get(:SomeRandomSymbol, 'to_i'), :SomeRandomSymbol.to_i
        
        assert_nothing_raised do
          # This will save it in a YAML file that acts as a backing
          # store for this election
          @et.save
        end

        # make sure the the YAML file name used for the backing store for
        # this election is correct
        file_name = @et.instance_variable_get(:@filename)
        assert_equal file_name, "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml"

        # should be able ot open the YAML file used for this
        # election's backing store.
        assert_nothing_raised Errno::ENOENT do
          # get the backing store file
          election_backing_store = YAML.load_file("#{Election::TRANSLATION_FOLDER}/election-#{@election.id}.#{@lang}.yml")
          
          # the key of the used for election storage
          backing_store_key = "Symbol-#{:SomeRandomSymbol.object_id}.to_i"
          # shd be in the backing store
          assert election_backing_store.has_key? backing_store_key
          # value shd be in the backing store          
          assert_equal election_backing_store[backing_store_key], :SomeRandomSymbol.to_i
        end
      end
    end
    
    context "spanish language" do
      setup do

        @election = Election.make
        @lang = 'es'
        @et = TTV::Translate::ElectionTranslation.new(@election, @lang)
      end
      
      teardown do
        # get rid of the YAML file that is the store for this election
        FileUtils.rm "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml", :force => true
      end
      
      should "be created " do
        assert @et
        assert_instance_of  TTV::Translate::ElectionTranslation,  @et
        assert_kind_of  TTV::Translate::ElectionTranslation,  @et
      end
      
      should "given a random object and a method warn that it needs translation" do
        random_string = "some string"
        # set the property, returns the result of calling "Some random string".size
        assert_equal @et.get(random_string, 'size'), 'NEEDSTRANSLATION'
        assert @et.dirty?
        
        assert_nothing_raised do
          @et.save
        end
        
        file_name = @et.instance_variable_get(:@filename)
        assert_equal file_name, "#{Rails.root}/db/translations/election-#{@election.id}.#{@lang}.yml"
        assert_nothing_raised Errno::ENOENT do
          # get the backing store file
          election_backing_store = YAML.load_file("#{Election::TRANSLATION_FOLDER}/election-#{@election.id}.#{@lang}.yml")

          backing_store_key = "String-#{random_string.object_id}.size"
          assert election_backing_store.has_key? backing_store_key
          
          # value shd NOT be in the backing store          
          assert_not_equal random_string.size, election_backing_store[backing_store_key]
          # value 'NEEDSTRANSLATION' shd be in the backing store                    
          assert_equal  'NEEDSTRANSLATION', election_backing_store[backing_store_key]
          
        end

      end
      
    end
    
  end
end
