# == Schema Information
# Schema version: 20100802153118
#
# Table name: jurisdiction_memberships
#
#  id              :integer         not null, primary key
#  user_id         :integer
#  district_set_id :integer
#  role            :string(255)     default("standard")
#  created_at      :datetime
#  updated_at      :datetime
#

class JurisdictionMembership < ActiveRecord::Base
  
  ROLE_NAMES = %w{  standard admin }
  
  belongs_to :user
  belongs_to :district_set
  
end
