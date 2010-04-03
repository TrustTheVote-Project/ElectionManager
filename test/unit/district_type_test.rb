require 'test_helper'
require 'district_type'

class DistrictTypeTest < ActiveSupport::TestCase
  
  def test_cache_constants
    DistrictType.all.each do |dt|
      assert_equal(DistrictType.const_get(dt.title.constant_name).id, dt.id, "Found District Type Constant for #{dt.title} ")
    end
    
  end
  
  def test_xml_representation

    DistrictType.all.each do |dt|
      assert_equal(DistrictType.xmlToId(dt.idToXml), dt.id, "District type xml representations")
    end
    
    assert_raise(NameError) do
      DistrictType.xmlToId('nosuchdistricttype')
    end
    
  end
  
end
