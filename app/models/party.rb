# == Schema Information
# Schema version: 20100813053101
#
# Table name: parties
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  ident        :string(255)
#

class Party < ActiveRecord::Base

  include ConstantCache

  cache_constants :key => :display_name

  def idToXml
    self.display_name.downcase
  end
  
  validates_presence_of :ident
  validates_uniqueness_of :ident, :message => "Non-unique Party ident attempted: {{value}}."

  # Make sure that ident is not nil. If it is, create a unique one.
  def before_validation
    if self.blank? || self.ident.blank?
      self.ident = "party-#{ActiveSupport::SecureRandom.hex}"
      self.save!
    end
  end

  def Party.xmlToId(xml)
    raise "unknown party #{xml}" unless const_get(xml.constant_name)
    const_get(xml.constant_name).id
  end

end
