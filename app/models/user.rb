class User < ActiveRecord::Base
  attr_accessible :email, :password, :password_confirmation
  
  acts_as_authentic do |c|
    c.merge_validates_length_of_password_field_options( { :minimum => 1, :too_short => "needs to be 1 chars"})
    c.ignore_blank_passwords=true
    c.perishable_token_valid_for=24.hours
  end

  def deliver_password_reset_instructions!  
    reset_perishable_token!
    Notifier.deliver_password_reset_instructions(self)  
  end

end
