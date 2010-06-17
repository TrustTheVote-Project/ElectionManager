# for public, not logged in, users
Given /^I am not logged in$/ do
  # nothing to done. A public user is an user that has not logged on
end

Given /^I am a public user$/ do
  # nothing to done. A public user is an user that has not logged on
end

# for standard, logged in, users
Given /^I am logged in$/ do
  login
end

Given /^I am a standard user$/ do
  login
end

Given /^I am a root user$/ do
  login(:role => 'root')
end

Given /^I login as a user with email: "([^\"]*)" and role: "([^\"]*)"$/ do |email, role|
  login(:role => 'root', :email => email)
end


# for a set of users 
Given /^[T|t]he following users$/ do |table|
  table.hashes.each do |hash|
    user = User.make(:email => hash['email'], :password => hash['password'], :password_confirmation => hash['password'])
    user.roles << UserRole.make(:name => hash['role'])
  end
end

Given /^[U|u]sers with the following roles$/ do |table|
  table.hashes.each do |hash|
    user = User.make
    user.roles << UserRole.make(:name => hash['role'])
  end
end

#Given /^I am a "([^\"]*)" user with "([^\"]*)"$/ do |role, email|
Given /^I am a user with a role of "([^\"]*)" and an email "([^\"]*)"$/ do |role, email|
  login(:email => email,:role => role)
end


Given /^I am logged in as one of the following users$/ do |table|
  table.hashes.each do |hash|
    login({:email => hash['email'], :password => hash['password'],:password_confirmation => hash['password'], :role => hash['role']})
  end
end

# Then /^I should see the users email within "([^\"]*)"$/ do |selector|
#    puts "TGD: current_user = #{controller.send(:current_user).email}"

#   within(selector) do |content|
#       hc = Webrat::Matchers::HasContent.new(controller.send(:current_user).email)
#       assert hc.matches?(content), hc.failure_message
#   end
# end

Then /^I should see the users jurisdiction within "([^\"]*)"$/ do |selector|
  within(selector) do |content|
      hc = Webrat::Matchers::HasContent.new( controller.send(:current_context).jurisdiction_name)
      assert hc.matches?(content), hc.failure_message
  end
end
  
Then /^I should have a user with email: "([^\"]*)" and role: "([^\"]*)"$/ do |email, role|
  u =  User.find_by_email(email)
  u || u.role?(role)
end

def login(options = {})
  options = {:role => 'standard'}.merge(options)
  user = User.make(options.except(:role))
  user.roles << UserRole.make(:name => options[:role])
  assert user, "could not create user"

  #  puts "TGD: user = #{user.inspect}"
  #  puts "TGD: user.roles = #{user.roles.map(&:name).inspect}"
  
  visit login_path
  fill_in "email", :with => user.email
  fill_in "password", :with => options[:password] || "password"
  click_button "Submit"
  # no current user
  assert controller.send(:current_user), "could not login user"
end

