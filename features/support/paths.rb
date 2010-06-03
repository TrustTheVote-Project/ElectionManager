module NavigationHelpers
  # Maps a name to a path. Used by the
  #
  #   When /^I go to (.+)$/ do |page_name|
  #
  # step definition in web_steps.rb
  #
  def path_to(page_name)
    case page_name
    
    when /the home\s?page/
      root_path
    when /the list page for (.+)/
      # ex: When I go to the list page for elections
      # will invoke self.send("elections_path")
      self.send("#{$1}_path")
    when /the show (.+) "([^\"]*)" page/i
      # model_name is $1,  display_name is $2
      klass = $1.camelize.constantize
      election_path(klass.find_by_display_name($2))
    when /the show page for that (.+)/
      polymorphic_path(model($1))
    when /the new (.+) page/i
      uri = self.send("new_#{$1}_path")
    when /the (.+) named "([^\"]*)"/i
      klass = $1.camelize.constantize
      election_path(klass.find_by_display_name($2))
      
    # Add more mappings here.
    # Here is an example that pulls values out of the Regexp:
    #
    #   when /^(.*)'s profile page$/i
    #     user_profile_path(User.find_by_login($1))

    # added by script/generate pickle path

    when /^#{capture_model}(?:'s)? page$/                           # eg. the forum's page
      path_to_pickle $1

    when /^#{capture_model}(?:'s)? #{capture_model}(?:'s)? page$/   # eg. the forum's post's page
      path_to_pickle $1, $2

    when /^#{capture_model}(?:'s)? #{capture_model}'s (.+?) page$/  # eg. the forum's post's comments page
      path_to_pickle $1, $2, :extra => $3                           #  or the forum's post's edit page

    when /^#{capture_model}(?:'s)? (.+?) page$/                     # eg. the forum's posts page
      path_to_pickle $1, :extra => $2                               #  or the forum's edit page

    when /^the (.+?) page$/                                         # translate to named route
      send "#{$1.downcase.gsub(' ','_')}_path"
  
    # end added by pickle path

    else
      raise "Can't find mapping from \"#{page_name}\" to a path.\n" +
        "Now, go and add a mapping in #{__FILE__}"
    end
  end
end

World(NavigationHelpers)
