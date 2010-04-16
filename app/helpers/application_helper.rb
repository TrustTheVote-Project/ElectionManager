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
  
  def user_navigation_helper
    content_tag(:div, :class =>"banner_right") do
      content_tag(:ul, :class => "wat-cf") do
        if current_user()
          content_tag(:li, "no jurisdiction selected") + 
          content_tag(:li) { link_to("change jurisdiction", change_jurisdiction_path)} +
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
  
  def jurisdiction_chooser_helper(jurisdiction)
#    content_tag(:div, :class => "banner_right") do
      if jurisdiction.nil?
        "none"
      else
        jurisdiction.display_name
      end
#    end
  end
end
