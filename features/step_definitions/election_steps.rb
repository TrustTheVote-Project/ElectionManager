Given /^I am a public user$/ do
  # nothing to done. A public user is an user that has not logged on
end

Given /^I have elections titled? (.+)$/ do |elections|
  elections.split(',').each do |election|
    Election.make(:display_name => election)
  end
end
Given /^I have election titled (.+)$/ do |election|
  Election.make(:display_name => election)
end

Given /^I have no elections$/ do
  Election.delete_all
end

