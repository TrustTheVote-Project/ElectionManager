require 'test_helper'
require 'ttv/import_export'
require 'election'

class ImportExportTest < ActiveSupport::TestCase
  
  def test_Import
    file = File.new( RAILS_ROOT + "/db/samples/BestDaddy2009.xml")
    DistrictSet.find(:all).each do |set|
      set.destroy
    end
    election = TTV::ImportExport.import(file)
    assert_not_nil(election)
    assert_not_nil(Election.find(election.id))
  end
  
  def test_Export
    file = File.new( RAILS_ROOT + "/db/samples/BestDaddy2009.xml")
    election = TTV::ImportExport.import(file)

    election = Election.find(:first)
    assert_not_nil(election, "Must have something to export in order to test it")
    xml = TTV::ImportExport.export(election)
    z = TTV::ImportExport.import(xml)
    assert_not_nil(z)
    assert_equal(election.display_name, z.display_name)
  end
  
end
