Given /^I am logged in$/ do
  std_user = User.make(:email => "foo@example.com", :password => "password")
  std_user.roles << UserRole.make(:name => 'standard')
  visit login_path
  fill_in "email", :with => "foo@example.com"
  fill_in "password", :with => "password"
  click_button "Submit"
end

Given /^I am a standard user$/ do
  std_user = User.make(:email => "foo@example.com", :password => "password")
  std_user.roles << UserRole.make(:name => 'standard')
  visit login_path
  fill_in "email", :with => "foo@example.com"
  fill_in "password", :with => "password"
  click_button "Submit"
end

