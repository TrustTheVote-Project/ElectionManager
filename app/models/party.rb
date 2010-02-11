# == Schema Information
# Schema version: 20100210222409
#
# Table name: parties
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Party < ActiveRecord::Base

  @@xml_ids = ['american_independent', 'democrat', 'green', 'independent', 'liberitarian', 'peace_and_freedom', 'republican']

  def idToXml
    @@xml_ids[self.id]
  end

  def Party.xmlToId(xml)
    @@xml_ids.each_with_index { |e, i| return i if e == xml}
    raise "Unknown party #{xml}"
  end

end
