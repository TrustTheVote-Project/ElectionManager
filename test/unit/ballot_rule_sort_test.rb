require 'test_helper'

class BallotRuleSortTest < ActiveSupport::TestCase
  
  context "District sorting strategy" do
    setup do
      @base_class = ::TTV::BallotRule::Base.new
      @districts = []
      10.times do |i|
        @districts << District.make(:display_name => "District#{i}", :position => rand(10))
      end
    end
    
    should "by default order district by position" do
      last_position = 0
      @districts.sort(&@base_class.district_ordering).each do |district|
        assert last_position <= district.position
        last_position = district.position
      end
    end
  end # end of context
  
  context "Contest sorting strategy" do
    setup do
    end
  end
  
  context "Question sorting strategy" do
    setup do
    end
  end

end
