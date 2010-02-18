# == Schema Information
# Schema version: 20100215144641
#
# Table name: voting_methods
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class VotingMethod < ActiveRecord::Base

  WINNER = 0
  RANKED = 1
  
  @@xml_codes = ['winner', 'ranked']

  def idToXml
    @@xml_codes[self.id]
  end

  def VotingMethod.xmlToId(code)
    case code
    when 'winner' then return WINNER
    when 'ranked' then return RANKED
    else raise "illegal voting method #{code}"
    end
  end
end
