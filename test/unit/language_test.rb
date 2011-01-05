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


class LanguageTest < ActiveSupport::TestCase
  context "basic insert test" do
    should "able to create new Language" do
      lang = Language.new(:display_name => "test language")
      lang.save!
    end
  end
  
  
  
  def test_dbLoaded
    assert_not_nil Language.find(0), "Default languages have not been loaded in the database. Run rake rake ttv:seed RAILS_ENV=development"
  end
  
  [
   { :display_name => "English", :code => 'es'},
   { :display_name => "Spanish", :code => "es"},
   { :display_name => "Chinese", :code => "zh"}
  ].each do |lang|
    context "Creating Language for #{lang[:display_name]}" do
      setup do
        Language.make(lang)
      end
      
      subject { Language.last }
      should_change("The number of languages", :by => 1){ Language.count }
      should_have_instance_methods :code, :display_name
      # should_have_db_columns :code, :display_name
      
      should "be valid" do
        assert_valid subject
      end
      
      should "have the right display name and code" do
        assert subject.display_name, lang[:display_name]
        assert subject.code, lang[:code]
      end
    end
  end
end
