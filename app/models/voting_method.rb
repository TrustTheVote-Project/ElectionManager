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

  DEFAULT = 0
  WINNER = 1
  RANKED = 2
  
  @@xml_codes = ['(built-in default voting method)', 'winner', 'ranked']

  def idToXml
    @@xml_codes[self.id]
  end

  def VotingMethod.xmlToId(code)
    case code.downcase
    when 'winner' then return WINNER
    when 'ranked' then return RANKED
    when '(built-in default voting method)' then return DEFAULT
    else raise "illegal voting method #{code}"
    end
  end
end
