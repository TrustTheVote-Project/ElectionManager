Given /^I have district sets titled? (.+)$/ do |ds|
  ds.split(',').each do |district_set|
    DistrictSet.make(:display_name => district_set)
  end
end

Given /^I have a district set titled "([^\"]*)"$/ do |ds|
  DistrictSet.make(:display_name => ds)
end

Given /^I have no district sets$/ do
  DistrictSet.delete_all
end

Then /^I should have a district set titled "([^\"]*)"$/ do |district_set_name|
  ds1 = DistrictSet.find_by_display_name(district_set_name)
  assert ds1
  assert district_set_name, ds1.display_name
end

When /^(?:|I )fill in District Set with the id for district set "([^\"]*)"$/ do |display_name|
  ds = DistrictSet.find_by_display_name(display_name)
  fill_in('District Set', :with => ds.id)
end
