When /^I delete (.+)$/ do |path_string|
  path = path_to(path_string)
  visit(path, :delete)
end

Then /^I should see text "([^\"]*)" within "([^\"]*)"$/ do |selector, text|
  within(selector) do |content|
    content.should contain(text)
  end
  # OR 
  #  response.should have_selector(selector, :content => text)
  # OR
  #  another way to do above
  #   response.should have_selector(selector) do |selector|
  #     selector.inner_html.should contain(text)
  #   end
end

Then /^I should see a link "([^\"]*)"$/ do |text|
  response.should have_selector("a", :content => text )
end
