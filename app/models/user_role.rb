class UserRole < ActiveRecord::Base
  ROLE_NAMES = %w{ root standard public}
  belongs_to :user
  validates_inclusion_of :name, :in => ROLE_NAMES, :message => "Invalid Role"

  def self.display_names
    ROLE_NAMES - ["public"]
  end
end
