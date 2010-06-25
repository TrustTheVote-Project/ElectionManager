# Look for text in a grid's row
Then /^I should see "([^\"]*)" in row (\d+)$/ do |text,row_offset|
  row_offset = row_offset.to_i + 1
  row_sel = ".table tr:nth-child(#{row_offset})" 
  within(row_sel) do |content|
    content.should contain(text)
  end
end

Then /^I should not see "([^\"]*)" in row (\d+)$/ do |text,row_offset|
  row_offset = row_offset.to_i + 1
  row_sel = ".table tr:nth-child(#{row_offset})" 
  within(row_sel) do |content|
    content.should_not contain(text)
  end
end

# Look for a text in a grid's row
# ex: Then I should see "Election 1" in the first row 
Then /^I should see "([^\"]*)" in the (.+) row$/ do |text, row_position|
  # TODO: ruby or rails must provide these mappings?
  pos = { 'first' => 1, 'second' => 2, 'third' => 3, 'fourth' => 4}
  row = pos[row_position]
  Then "I should see \"#{text}\" in row #{row}"
end

Then /^I should not see "([^\"]*)" in the (.+) row$/ do |text, row_position|
  # TODO: ruby or rails must provide these mappings?
  pos = { 'first' => 1, 'second' => 2, 'third' => 3, 'fourth' => 4}
  row = pos[row_position]
  Then "I should not see \"#{text}\" in row #{row}"
end

# Look for a link in a grid's row
Then /^I should see a link "([^\"]*)" in row (\d+)$/ do |text,row_offset|
  row_offset = row_offset.to_i + 1
  row_sel = ".table tr:nth-child(#{row_offset})"
  within(row_sel) do |content|
    content.should have_selector('a', :content => text )
  end
end

# Look for a link in a grid's row
# ex: Then I should see a link "Election 2" in the second row
Then /^I should see a link "([^\"]*)" in the (.+) row$/ do |text, row_position|
  # TODO: ruby or rails must provide these mappings?
  pos = { 'first' => 1, 'second' => 2, 'third' => 3, 'fourth' => 4}
  row = pos[row_position]
  Then "I should see a link \"#{text}\" in row #{row}"
end
