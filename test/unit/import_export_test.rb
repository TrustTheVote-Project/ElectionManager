require 'test_helper'
require 'ttv/import_export'
require 'shoulda'

class ImportExportTest < ActiveSupport::TestCase
  context "Importing an XML file" do
    setup do
      file = File.new( RAILS_ROOT + "/db/samples/BestDaddy2009.xml")
      DistrictSet.find(:all).each do |set|
        set.destroy
      end
      @election = TTV::ImportExport.import(file) 
    end
    
    should "not be nil" do
      assert_not_nil(@election)
      assert_not_nil(Election.find(@election.id))
    end
  
    should "contain 5 contests" do
      assert_equal 5, @election.contests.size 
      assert "Cooking", @election.contests.find_by_display_name("Cooking").display_name
    end
    
    should "retain contest order data" do
      assert_equal 2, @election.contests.find_by_display_name("Cooking").position
    end
  
  end

  context "exporting an XML file" do
    setup do
      file = File.new( RAILS_ROOT + "/db/samples/BestDaddy2009.xml")
      @election = TTV::ImportExport.import(file)
  
      @election = Election.find(:first)
      assert_not_nil(@election, "Must have something to export in order to test it")
      xml = TTV::ImportExport.export(@election)
      @new_xml = REXML::Document.new xml
    end
    
    should "export the display name" do
      assert_not_nil(@new_xml)
      display_name = @new_xml.root.attributes['display_name']
      assert_equal(@election.display_name, display_name)
    end
    
    should "export the contest display order" do
      assert_equal 2, @new_xml.root.elements["body/contest[@display_name='Cooking']"].attributes["order"].to_i
    end
    
  end
  
end
