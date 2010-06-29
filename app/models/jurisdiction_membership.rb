class JurisdictionMembership < ActiveRecord::Base
  
  ROLE_NAMES = %w{  standard admin }
  
  belongs_to :user
  belongs_to :district_set
  
end
