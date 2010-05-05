require 'test_helper'

class UserContextTest < ActiveSupport::TestCase
  
  context "basic UserContext" do
    setup do
      @uc = UserContext.new
    end
    should "successfully be created" do
      assert_not_nil @uc
    end
    
    should "not have any context yet" do
      assert !@uc.election? && !@uc.jurisdiction
    end
    
    context "with a basic jurisdiction" do
      setup do
        @jur = DistrictSet.make
        @uc.jurisdiction = @jur
        
      end
      
      should "locate primary name" do
        assert_equal @jur.display_name, @uc.jurisdiction_name
      end
      
      should "locate secondary name" do
        assert_equal @jur.second_name, @uc.jurisdiction_secondary_name
      end
    end
    
  end   
  
end
