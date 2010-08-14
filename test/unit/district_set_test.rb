require 'test_helper'

class DistrictSetTest < ActiveSupport::TestCase
  context 'initialization' do
    setup do
      @district_set = DistrictSet.make(:display_name => "District Set", :secondary_name => "It's a district!")
    end
     should 'be able to create a district set' do
       assert @district_set.save
       puts "TGD: district_set = #{@district_set.inspect}"
       assert_equal "District Set", @district_set.display_name
       assert_equal "It's a district!", @district_set.secondary_name
     end
      
    #should_have_attached_file :icon
    
    should 'have districts ' do
      10.times { @district_set.districts << District.make }
      districts = @district_set.districts
      assert districts
      assert_equal 10, districts.size
      
    end
  end
end
