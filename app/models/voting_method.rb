# == Schema Information
# Schema version: 20100802153118
#
# Table name: voting_methods
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class VotingMethod < ActiveRecord::Base
  
  include ConstantCache

  cache_constants :key => :display_name

  def idToXml
    self.display_name.downcase
  end

  def VotingMethod.xmlToId(xml)
    raise "illegal voting method #{xml}" unless const_get(xml.constant_name)
    const_get(xml.constant_name).id
  end
  
  def to_i
    id
  end
  
  def self.determine_default_voting_method(contest)
    VotingMethod.find(contest.election.default_voting_method_id)
  end
  
end
