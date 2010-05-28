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

# Look for a text in a grid's row
Then /^I should see "([^\"]*)" in row "(\d+)"$/ do |text,row_offset|
  row_sel = ".table tr:nth-child(#{row_offset})" 
  within(row_sel) do |content|
    content.should contain(text)
  end
end

# Look for a link in a grid's row
Then /^I should see a link "([^\"]*)" in row "(\d+)"$/ do |text,row_offset|
  row_sel = ".table tr:nth-child(#{row_offset})" 
  within(row_sel) do |content|
    content.should have_selector('a', :content => text )
  end
end

Then /^I should see a link "([^\"]*)"$/ do |text|
  response.should have_selector("a", :content => text )
end
