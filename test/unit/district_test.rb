require 'test_helper'

class DistrictTest < ActiveSupport::TestCase
  context "basic test" do
    should "able to create new district" do
      prec = District.new(:display_name => "i am new")
      prec.save!
   end
  end
end
