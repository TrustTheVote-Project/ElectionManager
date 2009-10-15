require 'test_helper'
require 'district_type'

class DistrictTypeTest < ActiveSupport::TestCase
  
  def test_xml_representation
    DistrictType.find(:all).each do |dt|
      assert_equal(DistrictType.xmlToId(dt.idToXml), dt.id, "District type xml representations")
    end
  end
  
end
