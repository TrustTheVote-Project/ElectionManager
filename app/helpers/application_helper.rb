# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  def render_error_messages(model, options={})
    options = { :verbose => false }.merge(options)
    messages = model.errors.full_messages #objects.compact.map { |o| o.errors.full_messages}.flatten
    render :partial => 'layouts/error_messages', :object => messages, 
      :locals => { :options => options, :model => model} unless messages.empty?
  end
  
  #
  # Pretty print objects, to be used in views
  #
  def pp_debug(obj)
    '<pre>' +
    h(obj.pretty_inspect) +
    '</pre>'
  end

  def icon_helper
    curr_jurisd = session[:jurisdiction]
    if curr_jurisd.nil? or !DistrictSet.find(curr_jurisd).icon?
      link_to(image_tag("ttv-100.png", :class => "ttv-logo"), :current_jurisdiction)
    else
      link_to(image_tag(DistrictSet.find(curr_jurisd).icon.url(:thumb), :class => "ttv-logo"), :current_jurisdiction)
    end
  end

  def icon_for district_set
   return image_tag("ttv-100.png", :class =>"avatar") unless district_set.icon?
   return image_tag(district_set.icon.url(:thumb), :class => "avatar") if district_set.icon?
  end

  def link_icon_for district_set
    link_to(icon_for(district_set), set_jurisdiction_path(district_set))
  end

  def header_helper
    curr_jurisd = session[:jurisdiction]
    if curr_jurisd.nil?
      jurisdiction_name = "no jurisdiction selected"
      jurisdiction_secondary = ""
    else
      jurisdiction_name = DistrictSet.find(curr_jurisd).display_name
      if DistrictSet.find(curr_jurisd).secondary_name.nil?
        jurisdiction_secondary = ""
      else
        jurisdiction_secondary = DistrictSet.find(curr_jurisd).secondary_name
      end
    end
    if current_user() and jurisdiction_name != "no jurisdiction selected"
      content_tag(:h1, jurisdiction_name +
                      "<br /><small>" + jurisdiction_secondary + "</small>", :class=>"title-header")
    else
      content_tag(:h1, "TTV Election Manager", :class=>"title-header") 
    end
    
  end
  
  def user_navigation_helper
    curr_jurisd = session[:jurisdiction]
    if curr_jurisd.nil?
      jurisdiction_name = "no jurisdiction selected"
      jurisdiction_secondary = ""
    else
      jurisdiction_name = DistrictSet.find(curr_jurisd).display_name
      if DistrictSet.find(curr_jurisd).secondary_name.nil?
        jurisdiction_secondary = ""
      else
        jurisdiction_secondary = DistrictSet.find(curr_jurisd).secondary_name
      end
    end
    content_tag(:div, :class =>"banner_right") do
      content_tag(:ul, :class => "wat-cf") do
        if current_user()
          content_tag(:li, jurisdiction_name + " " + link_to(" (change)", change_jurisdiction_path) +
                      "<br /><small>" + jurisdiction_secondary + "</small>") +
          content_tag(:li) { current_user.email } + 
          content_tag(:li) { link_to("Edit profile", edit_user_path(:current)) } +
          content_tag(:li) { link_to("Logout", logout_path) }
        else
          content_tag(:li) { link_to("Login", login_path) } + 
          content_tag(:li) { link_to("Register", new_user_path) }
        end
      end
    end
  end
   
  def button_link_helper(image_file, alt_tag, button_label, link_path, delete=nil)
    options = {}
    if (delete == :delete)
      options = {:method => "delete", :confirm => "#{t("web-app-theme.confirm", :default => "Are you sure?")}"}
    end
    link_to("#{image_tag(image_file, :alt => alt_tag)} #{button_label}", link_path, {:class => "button"}.merge(options))
  end

end
