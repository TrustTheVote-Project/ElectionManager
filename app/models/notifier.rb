class Notifier < ActionMailer::Base
  
  def password_reset_instructions(user)  
    logger.info("user is #{user}")
    subject       "TTV Password Reset Instructions"  
    from "Aleks TTV Totic <a@totic.org>"
    recipients    user.email  
    sent_on       Time.now  
    body          :edit_password_reset_url => edit_password_reset_url(user.perishable_token), :user => user
  end
  
  def registration_confirmation(user)
    recipients user.email
    from "Aleks TTV Totic <a@totic.org>"
    subject "Welcome to TTV system"
    body :user => user
  end
end
