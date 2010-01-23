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
