class UserContext
  attr_accessor :current_jurisdiction
  
  def current_jurisdiction?
    !@current_jurisdiction.nil?
  end
  
  def current_jurisdiction_name
    if @current_jurisdiction
      @current_jurisdiction.display_name
    else
      "no jurisdiction selected"
    end
  end
  
  def current_jurisdiction_secondary_name
    if @current_jurisdiction
      @current_jurisdiction.secondary_name
    else
      "no jurisdiction selected"
    end
  end
  
end
