# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time

  # See ActionController::RequestForgeryProtection for details
  protect_from_forgery 

  # Scrub sensitive parameters from your log
  filter_parameter_logging :password,:confirm_password
  
  helper_method :current_user, :pretty_date, :pluralize
  
  before_filter :disable_etags
  after_filter :flash_xhr
  
  rescue_from CanCan::AccessDenied do |exception|
    flash[:error] = "Access Denied"
    redirect_to root_url
  end
  
  def disable_etags
    # TODO remove this function when in production
    fresh_when(:etag => rand)
  end
  
private

  def pluralize(count, singular, plural = nil)
    "#{count || 0} " + ((count == 1 || count == '1') ? singular : (plural || singular.pluralize))
  end
  
  # displays flash errors for Ajax requests
  def flash_xhr
    return if ! (request.xhr? && Mime::Type.lookup(response.content_type) == :js)
    headers['X-JSON'] = flash.to_json;
    flash.discard
  end
  
  def pretty_date(d)
    return d.strftime("%A, %B %d %Y, %I:%M %p %Z") if d.respond_to? :strftime
    return d.to_s unless d.nil?
    return "unspecified date"
  end
  
  # 
  # Authlogic authenticatoin methods
  #
  #authlogic
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  #authlogic
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  #authlogic
  def require_user
    unless current_user
      store_location
      flash[:notice]    = "You must be logged in to access this page"
      redirect_to new_user_session_url
      return false
    end
  end

  #authlogic
  def require_no_user
    if current_user
      store_location
      flash[:notice]    = "You must be logged out to access this page"
      redirect_to account_url
      return false
    end
  end

  #authlogic
  def store_location
    session[:return_to] = request.request_uri
  end

  #authlogic
  def redirect_back_or_default(default)
    redirect_to(session[:return_to] || default)
    session[:return_to] = nil
  end

end
