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

# TODO: odd behaviour to the YamlTranslation class. Can't assign a
# value that will be saved/persisted to backing store?

class YamlTranslationTest < ActiveSupport::TestCase
  context "TTV::Translate::ElectionTranslation" do
    
    setup do
      @backing_store_filename = "#{Rails.root}/ballots/mass/lang/en/ballot.yml"
      # dummy backing store
      dummy_backing_store = {"some_key" => "some_value"}
      YAML.expects(:load_file).with(@backing_store_filename).returns(dummy_backing_store)
    end
    
    should "get an existing key/value pair in the backing store" do
      yt = TTV::Translate::YamlTranslation.new(@backing_store_filename)
      assert "some_value", yt["some_key"]
    end
    
    should "not be dirty when getting an existing key/value pair from backing store" do
      yt = TTV::Translate::YamlTranslation.new(@backing_store_filename)
      yt["some_key"]      
      assert !yt.dirty?
    end
    
    should "be dirty after trying to get a missing key/value pair from the backing store" do
      yt = TTV::Translate::YamlTranslation.new(@backing_store_filename)
      yt["missing_key"]      
      assert yt.dirty?
    end
    
    should "not allow save if not dirty" do
      yt = TTV::Translate::YamlTranslation.new(@backing_store_filename)
      yt["some_key"]
      assert !yt.dirty?
      File.expects(:open).never
      yt.save
    end
    
     should "allow save if dirty" do
       yt = TTV::Translate::YamlTranslation.new(@backing_store_filename)
       yt["missing_key"]
       assert yt.dirty?
       File.expects(:open).with(@backing_store_filename, 'w')
       yt.save
     end
  end # end context
  
  context "persisting into backing store" do
    setup do
      @backing_store_filename = "#{Rails.root}/ballots/mass/lang/en/ballot.yml"
      @yt = TTV::Translate::YamlTranslation.new(@backing_store_filename)
    end
    
    should "not be allowed to set a value in the backing store" do
      assert_raise NoMethodError do
        @yt["some_key"] = "some_value"
      end
    end
  end # end context
end
