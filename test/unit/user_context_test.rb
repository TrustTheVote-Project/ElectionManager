require 'test_helper'

class UserContextTest < ActiveSupport::TestCase

  context "basic test" do
    should "able to create new district" do
      assert_not_nil UserContext.new
   end
  end
end
