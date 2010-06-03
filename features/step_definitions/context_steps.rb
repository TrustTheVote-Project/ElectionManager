Given /^I have no current jurisdiction$/ do
  assert_nil @controller.current_context.jurisdiction
end
