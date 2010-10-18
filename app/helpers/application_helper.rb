# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  # Nice styling of error messages
  def render_error_messages(model, options={})
    options = { :verbose => false }.merge(options)
    messages = model.errors.full_messages #objects.compact.map { |o| o.errors.full_messages}.flatten
    render :partial => 'layouts/error_messages', :object => messages, 
      :locals => { :options => options, :model => model} unless messages.empty?
  end
  
 # @TODO: change a little when DistrictSet and Jurisdiction model are disentangled
  def jurisdiction_logo_thumbnail(jurisd)
    if jurisd.nil? || !jurisd.has_logo?
      image_tag("ttv-100.png", :class =>"avatar")
    else
      ass = Asset.ident_is(jurisd.logo_ident).first
      image_tag(ass.asset.url(:thumb), :class => "avatar")
    end
  end

  def icon_helper
    curr_jurisd = current_context.jurisdiction
    if curr_jurisd.nil? or !DistrictSet.find(curr_jurisd).icon?
      link_to(image_tag("ttv-100.png", :class => "ttv-logo"), :current_jurisdictions)
     else
      link_to(image_tag(DistrictSet.find(curr_jurisd).icon.url(:thumb), :class => "ttv-logo"), :current_jurisdictions)
     end
   end

  def link_logo_for jurisdiction
    link_to(jurisdiction_logo_thumbnail(jurisdiction), :current_jurisdictions)
  end

  # HTML for header that is over all pages
  def header_helper
    jurisdiction_name = current_context.jurisdiction_name
    jurisdiction_secondary = current_context.jurisdiction_secondary_name
    
    if current_user() and current_context.jurisdiction?
      content_tag(:h1, jurisdiction_name +
                      "<br /><small>" + jurisdiction_secondary + "</small>", :class=>"title-header")
    else
      content_tag(:h1, "TTV Election Manager", :class=>"title-header") 
    end
    
  end
  
  # HTML for top right user navigation bar where login etc live
  def user_navigation_helper
    jurisdiction_name = current_context.jurisdiction_name
    content_tag(:div, :class =>"banner_right") do
      content_tag(:ul, :class => "wat-cf") do
        if current_user()
          content_tag(:li, jurisdiction_name + " " + link_to(" (change)", change_jurisdictions_path)) +
          content_tag(:li) { current_user.email } + 
          content_tag(:li) { link_to("Edit profile", edit_user_path(current_user)) } +
          content_tag(:li) { link_to("Logout", logout_path) }
        else
          content_tag(:li) { link_to("Login", login_path) } + 
          content_tag(:li) { link_to("Register", register_user_path) }
        end
      end
    end
  end
  
  # HTML for nicely styled buttons in forms
  def button_link_helper(image_file, alt_tag, button_label, link_path, delete=nil)
    options = {}
    if (delete == :delete)
      options = {:method => "delete", :confirm => "#{t("web-app-theme.confirm", :default => "Are you sure?")}"}
    end
    link_to("#{image_tag(image_file, :alt => alt_tag)} #{button_label}", link_path, {:class => "button"}.merge(options))
  end
  
  # HTML for breadcrums
  def breadcrumb_helper(cc)
    html = ""
    jur_link = ""
    el_link = ""
    c_or_q_or_p_link = ""
    if cc.contest?
      c_or_q_or_p_link = link_to(cc.contest.display_name, cc.contest)
    end
    if cc.question?
      c_or_q_or_p_link = link_to(cc.question.display_name, cc.question)
    end
    if cc.precinct?
      c_or_q_or_p_link = link_to(cc.precinct.display_name, cc.precinct)
    end
    if cc.election?
      el_link = link_to(cc.election.display_name, cc.election)
    end
    if cc.jurisdiction?
      jur_link = link_to(cc.jurisdiction.display_name, set_jurisdiction_path(cc.jurisdiction))
    end
    if c_or_q_or_p_link != ""
      html = c_or_q_or_p_link + content_tag(:small, " (in " + el_link + " in " + jur_link + " )")
    elsif el_link != ""
      html = el_link + content_tag(:small, " (in " + jur_link + " )")
    elsif jur_link
      html = jur_link
    end
#    html <<  + cc.to_s
    content_tag(:h4, html)
  end
end
