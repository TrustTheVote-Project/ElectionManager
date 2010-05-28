Given /^I have elections titled? (.+)$/ do |elections|
  elections.split(',').each do |election|
    Election.make(:display_name => election)
  end
end

Given /^I have an election titled (.+)$/ do |election|
#Given /^I have an election titled "([^\"]*)"$/ do |election|
  Election.make(:display_name => election)
end

Given /^I have no elections$/ do
  Election.delete_all
end

Then /^I should have "(\d+)" elections$/ do |election_count|
  assert Election.count, election_count.to_i
end

Then /^I should have an election titled "([^\"]*)"$/ do |election_name|
  e1 = Election.find_by_display_name(election_name)
  assert e1
  assert election_name, e1.display_name
end
