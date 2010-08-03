# == Schema Information
# Schema version: 20100802153118
#
# Table name: languages
#
#  id           :integer         not null, primary key
#  display_name :string(255)
#  code         :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#

class Language < ActiveRecord::Base
end
