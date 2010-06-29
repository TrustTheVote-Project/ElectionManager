# == Schema Information
# Schema version: 20100215144641
#
# Table name: users
#
#  id                 :integer         not null, primary key
#  email              :string(255)
#  crypted_password   :string(255)
#  password_salt      :string(255)
#  persistence_token  :string(255)
#  perishable_token   :string(255)
#  failed_login_count :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation, :roles_attributes
  
  has_many :roles, :class_name => "UserRole", :dependent => :destroy
  accepts_nested_attributes_for :roles, :reject_if => proc{ |role_name| role_name[:name].blank? }, :allow_destroy => true
  
  has_many :jurisdiction_users, :class_name => "JurisdictionUser"
  has_many :jurisdictions, :through => :jurisdiction_users, :source => :district_set
  
  def role?(role_name)
    # roles.map(&:name)  build an array of role names for this user.
    # include?(role_name.to_s)  check if the role_name param is in
    # this array
    role_name && !roles.blank? && roles.map(&:name).include?(role_name.to_s)
  end
  
  
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options( { :minimum => 1, :too_short => "needs to be 1 chars"})
    c.ignore_blank_passwords=true
    c.perishable_token_valid_for=24.hours
  end

  def deliver_password_reset_instructions!  
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)  
  end
  
  # define boolean methods for each role.
  # root? ,  standard?, public?, ...
  UserRole::ROLE_NAMES.each do |role|
    define_method("#{role}?".to_sym) do
      !roles.empty? && roles.map(&:name).include?(role)      
    end
  end
  
  def jurisdiction_admin?
    !jurisdictions.empty? && jurisdiction_users.map(&:role).include?('admin')
  end

  def jurisdiction_member?(jurisdiction)
    jurisdiction && jurisdictions.include?(jurisdiction)
  end
  
end
