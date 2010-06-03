Given /^there are jurisdictions titled (.+)$/ do |jurisdictions|
  jurisdictions.split(',').each do |a_jurisdiction|
    DistrictSet.make(:display_name => a_jurisdiction)
  end
end

When /^choose jurisdiction "([^\"]*)"$/ do |link|
  click_link(link)
end

