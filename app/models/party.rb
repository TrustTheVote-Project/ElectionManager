class Party < ActiveRecord::Base

  @@xml_ids = ['independent', 'democrat', 'republican', 'liberitarian']

  def idToXml
    @@xml_ids[self.id]
  end

  def Party.xmlToId(xml)
    @@xml_ids.each_with_index { |e, i| return i if e == xml}
    raise "Unknown party #{xml}"
  end

end
