class VotingMethod < ActiveRecord::Base

  @@xml_codes = ['winner', 'ranked']

  def idToXml
    @@xml_codes[self.id]
  end

  def VotingMethod.xmlToId(code)
    case code
    when 'winner' then return 0 
    when 'ranked' then return 1
    else raise "illegal voting method #{code}"
    end
  end
end
