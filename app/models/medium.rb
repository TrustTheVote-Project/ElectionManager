# == Schema Information
# Schema version: 20100802153118
#
# Table name: media
#
#  id           :integer         not null, primary key
#  format       :string(255)
#  created_at   :datetime
#  updated_at   :datetime
#  display_name :string(255)
#

class Medium < ActiveRecord::Base
end
