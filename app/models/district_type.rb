# == Schema Information
# Schema version: 20100813053101
#
# Table name: district_types
#
#  id         :integer         not null, primary key
#  title      :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class DistrictType < ActiveRecord::Base
  
  include ConstantCache

#TODO rps: Change district :title to :display_name 
  cache_constants :key => :title
  attr_accessible :title

# TODO: I am pretty sure these two are no longer required.
  def DistrictType.xmlToId(xml)
    raise "unknown district type #{xml}" unless const_get(xml.constant_name)
    const_get(xml.constant_name).id
  end
  
  def idToXml
    self.title.downcase
  end
end
