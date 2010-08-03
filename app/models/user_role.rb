# == Schema Information
# Schema version: 20100802153118
#
# Table name: user_roles
#
#  id         :integer         not null, primary key
#  user_id    :integer
#  name       :string(255)
#  created_at :datetime
#  updated_at :datetime
#

class UserRole < ActiveRecord::Base
  ROLE_NAMES = %w{ root standard public}
  belongs_to :user
  validates_inclusion_of :name, :in => ROLE_NAMES, :message => "Invalid Role"

  def self.display_names
    ROLE_NAMES - ["public"]
  end
end
