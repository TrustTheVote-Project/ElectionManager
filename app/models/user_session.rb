class UserSession < Authlogic::Session::Base
  generalize_credentials_error_messages "Your login information is invalid."
  find_by_login_method :find_by_email
  
#  attr_accessible :election_id
  
  def election
    return Election.find(@election_id) if (@election_id && election = Election.find(@election_id))
    election = Election.find(:last, :order => 'created_at')
    @election_id = election.id if election
    return election
  end
  
  def election_id=(election_id)
    @election_id = election_id
  end
end