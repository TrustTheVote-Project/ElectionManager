Feature: Manage Context
  In order to know where I am
  I want to see the correct breadcrumb
 
	@wip
  Scenario: Show "Choose Jurisdiction" when no Jurisdiciton
  	Given I am a standard user
  	And I have no current jurisdiction
  	And there are jurisdictions titled Jurisdiction 1, Jurisdiction 2
  	Then I should see "none selected" within #current_jurisdiction

  Scenario: Choose new current jurisdiction
  	Given I am a standard user
  	And I have Jurisdiction 1, Jurisdiction 2
  	And I see the list of jurisdictions
  	And I choose Jurisdiction 2
  	Then I should see the list of elections in Jurisdiction 2
 