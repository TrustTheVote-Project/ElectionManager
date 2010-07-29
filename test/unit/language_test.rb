require 'test_helper'

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
      should_have_db_columns :code, :display_name
      
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
