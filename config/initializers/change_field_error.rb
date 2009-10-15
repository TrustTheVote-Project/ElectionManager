# as advised by http://www.pragprog.com/screencasts/v-rbforms/mastering-rails-forms
# customizes the way form errors are displayed

ActionView::Base.field_error_proc = Proc.new do |html_tag, instance_tag|
  if html_tag =~ /type=.hidden./ || html_tag =~/<label/
    html_tag
  else 
    "<span class='field_error'>#{html_tag}</span> " +
    "<span class='error_message'>Error: #{ instance_tag.method_name.humanize} #{[instance_tag.error_message].flatten.first}.</span>"
  end
end