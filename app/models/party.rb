# == Schema Information
# Schema version: 20100215144641
#
# Table name: parties
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Party < ActiveRecord::Base


  @@xml_ids = ['default', 'american_independent', 'democrat', 'green', 'independent', 'liberitarian', 'peace_and_freedom', 'republican']

  def idToXml
    @@xml_ids[self.id]
  end
  
  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique Party ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "party-#{SecureRandom.hex}"
      self.save!
    end
  end

  def Party.xmlToId(xml)
    @@xml_ids.each_with_index { |e, i| return i if e == xml}
    raise "Unknown party #{xml}"
  end

end
