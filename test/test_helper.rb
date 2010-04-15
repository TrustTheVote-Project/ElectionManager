ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'test_help'
require 'shoulda'

class ActiveSupport::TestCase
  # Transactional fixtures accelerate your tests by wrapping each test method
  # in a transaction that's rolled back on completion.  This ensures that the
  # test database remains unchanged so your fixtures don't have to be reloaded
  # between every test method.  Fewer database queries means faster tests.
  #
  # Read Mike Clark's excellent walkthrough at
  #   http://clarkware.com/cgi/blosxom/2005/10/24#Rails10FastTesting
  #
  # Every Active Record database supports transactions except MyISAM tables
  # in MySQL.  Turn off transactional fixtures in this case; however, if you
  # don't care one way or the other, switching from MyISAM to InnoDB tables
  # is recommended.
  #
  # The only drawback to using transactional fixtures is when you actually 
  # need to test transactions.  Since your test is bracketed by a transaction,
  # any transactions started in your code will be automatically rolled back.
  self.use_transactional_fixtures = true

  # Instantiated fixtures are slow, but give you @david where otherwise you
  # would need people(:david).  If you don't want to migrate your existing
  # test cases which use the @david style and don't mind the speed hit (each
  # instantiated fixtures translates to a database query per test method),
  # then set this back to true.
  self.use_instantiated_fixtures  = false
  
  # Setup all fixtures in test/fixtures/*.(yml|csv) for all tests in alphabetical order.
  #
  # Note: You'll currently still have to declare fixtures explicitly in integration tests
  # -- they do not yet inherit this setting
  # fixtures :all

  # Add more helper methods to be used by all tests here...

  
  # create a macro that will be used to test question requesters
  def self.setup_question_requesters
    context "question requesters setup" do
      setup do
        # create a precint within 4 Districts
        @p1 = Precinct.create!(:display_name => "Precint 1")
        (0..3).each do |i|
          @p1.districts << District.new(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
        end
        
        # create another precint with another set of 4 Districts
        @p2 = Precinct.create!(:display_name => "Precint 2")      
        (4..7).each do |i|
          @p2.districts << District.create!(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
        end

        # create a set of districts that are not associated with any precincts
        (8..11).each do |i|
          District.create!(:display_name => "District #{i}", :district_type => DistrictType::COUNTY)
        end
        
        # create a district set with only the first 2 districts in the
        # first precinct
        ds1  = DistrictSet.create!(:display_name => "District Set 1")
        ds1.districts << District.find_by_display_name("District 0")
        ds1.districts << District.find_by_display_name("District 1")
        ds1.save!
        
        # create another district set that is associated first 2 districts
        # in the second precinct
        ds2  = DistrictSet.create!(:display_name => "District Set 2")
        ds2.districts << District.find_by_display_name("District 4")
        ds2.districts << District.find_by_display_name("District 5")
        ds2.save!

        # create 2 elections each associated with a district set
        @e1 = Election.create!(:display_name => "Election 1", :district_set => ds1)
        @e2 = Election.create!(:display_name => "Election 2", :district_set => ds2)

        # create 4 questions that where requested by the district 0,
        # district 0 is associated with the first precinct 
        d0 =  District.find_by_display_name("District 0")
        (0..3).each do |i|
          q = Question.new(:display_name => "Question #{i}", :question => "what is #{i}")
          q.requesting_district = d0
          q.election = @e1
          q.save!
        end

        # create 4 questions that where requested by the district 4,
        # district 2 is overlaps the second precinct 
        d4 =  District.find_by_display_name("District 4")
        
        (4..7).each do |i|
          q = Question.new(:display_name => "Question #{i}", :question => "what is #{i}")
          q.requesting_district = d4
          q.election = @e2
          q.save!

        end
      end
      # yield to the context in the test
      yield
      
    end
  end

end
