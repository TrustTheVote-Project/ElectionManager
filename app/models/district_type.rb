# == Schema Information
# Schema version: 20100215144641
#
# Table name: district_types
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class DistrictType < ActiveRecord::Base

  @@xmlid = 
  { '(built-in default district type)' => 0, 
    'state' => 1, 
    'county' => 2, 
    'municipality' => 3, 
    'school' => 4,
    'water' => 5,
    'fire' => 6,
    'coastal' => 7,
    'harbor' => 8 
  }
    
  def DistrictType.xmlToId(xml)
    raise "unknown district type #{xml}" unless @@xmlid[xml]
    @@xmlid[xml]
  end
  
  def idToXml
    self.title.downcase
  end

end
