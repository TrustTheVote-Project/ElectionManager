require 'test_helper'
require 'ttv/yaml_import'


class YAMLImportTest < ActiveSupport::TestCase

  context "Using generated.yml for import" do
    setup do
      @file = File.new("#{RAILS_ROOT}/test/elections/generated.yml")
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
      
      should "have the right election date" do
        assert "2010-11-08", @elect.start_date.to_date.to_s
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
      
      should "process ranked voting method correctly" do
        cont = Contest.find_by_display_name "State Representative1"
        assert_equal VotingMethod::RANKED, cont.voting_method
      end
      
     should "process winner voting method correctly" do
        cont = Contest.find_by_display_name "Representative in Congress"
        assert_equal VotingMethod::WINNER_TAKE_ALL, cont.voting_method
      end

     should "process default voting method correctly" do
        cont = Contest.find_by_display_name "State Representative2"
        assert_equal VotingMethod::WINNER_TAKE_ALL, cont.voting_method
      end
    end
  end
  
  context "using tiny" do
    setup do
      afile = File.new("#{RAILS_ROOT}/test/elections/tiny.yml")
      importer = TTV::YAMLImport.new(afile)
      importer.import
      @e = Election.find_by_display_name("One Contest Election")
    end
    
    should "import should get an election of the right name" do
      assert_equal "One Contest Election", @e.display_name
      assert_valid @e
    end
    
    should "have one contest with correct name, candidate" do
      assert_equal 1, @e.contests.length
      assert_equal "Representative in Congress",@e.contests[0].display_name
      assert_equal "Kristin Curtis", @e.contests[0].candidates[0].display_name
      assert_equal "Democrat", @e.contests[0].candidates[0].party.display_name
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
    end
    
    context "yaml file of type ballot_config" do
      setup do
        afile = File.new("#{RAILS_ROOT}/test/elections/ballot_config.yml")
        importer = TTV::YAMLImport.new(afile)
        @e = importer.import

      end
      
      should "be imported and give the right town" do
        assert_valid @e
      end
    end
  end
  
  context "Using 101.26.yml for import" do
    setup do
      afile = File.new("test/elections/xml/101.26.yml")
      importer = TTV::YAMLImport.new(afile)
      @e = importer.import
    end
  
    should "import 1 question" do
      assert_equal 1, @e.questions.length
      assert_equal "State Initiative Measure 1033", @e.questions[0].display_name
      assert_equal  "Initiative Measure No. 1033 concerns state, county and city revenue. | |This measure would limit growth of certain state, county and city revenue to annual inflation and population growth, not including voter-approved revenue increases. Revenue collected above the limit would reduce property tax levies.  | |Should this measure be enacted into law? Yes [ ] No [ ]",
                    @e.questions[0].question
    end
    
    should "retain contest order information" do
      assert_equal 445, @e.contests.find_by_display_name("Fire Protection Dist 13 Fire Commissioner Position #3").order
    end 
  end
end
