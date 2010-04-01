require 'test_helper'
require 'pp'
require 'ttv/yaml_import'


class YAMLImportTest < ActiveSupport::TestCase
  
  context "Using generated.yml for import" do
    setup do
      @file = File.new("test/elections/generated.yml")
      @import_obj = TTV::YAMLImport.new(@file)
    end
    
    should "import should get an election of the right name" do
      @import_obj.import
      assert_equal "2012 Presidential", @import_obj.election.display_name
      assert_valid @import_obj.election
    end
    
    context "and imported ok then" do
      setup do
        @ds_count = DistrictSet.all.length
        @import_obj.import
        @elect = @import_obj.election
        assert_valid @elect
      end
      
      should "have the right number of precincts overall" do
        prec = Precinct.find(:all)
        assert_equal 9, prec.length
      end
      
      should "have 10 contests" do
        cont = Contest.find(:all)
        assert_equal 10, cont.length
      end
      
      should "have 1 district set" do
        ds = DistrictSet.find(:all)
        assert_valid @elect.district_set
        assert_equal 1, ds.length - @ds_count
      end
    end
  end
  
  context "using tiny" do
    setup do
      afile = File.new("test/elections/tiny.yml")
      importer = TTV::YAMLImport.new(afile)
      importer.import
      @e = Election.find_by_display_name("One Contest Election")
    end
    
    should "import should get an election of the right name" do
      assert_equal "One Contest Election", @e.display_name
      assert_valid @e
    end
    
    should "have one contest with the right name and the right candidate" do
      assert_equal 1, @e.contests.length
      assert_equal "Representative in Congress",@e.contests[0].display_name
      assert_equal "Kristin Curtis", @e.contests[0].candidates[0].display_name
      @c = Election.find_by_display_name("One Contest Election")
      assert_valid @c
    end
    
    should "have one or more precincts associated with it" do
      ds = @e.district_set
      assert_valid ds
      d = ds.districts
      assert d.length > 0
      d.each do |a_dist|
        assert_valid a_dist
        prec_list = a_dist.precincts
        prec_list.each { |prec| assert_valid prec }
      end
    end
    
    should "have one district with the right ident" do
      assert_equal 1, @e.districts.length
      assert_equal "City of Random",@e.districts[0].display_name
      puts "heybrian"
    end
    
    context "yaml file of type ballot_config" do
      setup do
        afile = File.new("test/elections/ballot_config.yml")
        importer = TTV::YAMLImport.new(afile)
        @e = importer.import

      end
      
      should "be imported and give the right town" do
        puts @e.inspect
        puts @e.contests.inspect
        assert_valid @e
      end
    end
  end
end

  
