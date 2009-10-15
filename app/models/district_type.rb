class DistrictType < ActiveRecord::Base

  @@xmlid = { 'state' => 0, 
    'county' => 1, 
    'municipality' => 2, 
    'school' => 3,
    'water' => 4,
    'fire' => 5,
    'coastal' => 6,
    'harbor' => 7 
  }
    
  def DistrictType.xmlToId(xml)
    raise "unknown district type #{xml}" unless @@xmlid[xml]
    @@xmlid[xml]
  end
  
  def idToXml
    self.title.downcase
  end

end
