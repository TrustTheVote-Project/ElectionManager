require 'test_helper'

class DistrictSetTest < ActiveSupport::TestCase
    context 'initialization' do
    
      should 'be able to create a district set' do
  
        district_set = DistrictSet.new(:display_name => "District Set", :secondary_name => "It's a district!")
        
        assert district_set.save
        assert_equal "District Set", district_set.display_name
        assert_equal "It's a district!", district_set.secondary_name
      end
      
      should_have_attached_file :icon
    
  end
end
