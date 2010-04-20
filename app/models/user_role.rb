class UserRole < ActiveRecord::Base

  belongs_to :user
  validates_inclusion_of :name, :in => %w{ root standard public}, :message => "Invalid Role"
end
