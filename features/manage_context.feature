@header
Feature: Manage Context
  In order to know where I am
  I want to see the correct breadcrumb
 
	@wip
  Scenario: Show "Choose Jurisdiction" when no Jurisdiciton
  	Given I am a standard user
  	And I have no current jurisdiction
  	And there are jurisdictions titled Jurisdiction 1, Jurisdiction 2
  	Then I should see "none selected" within "#user-navigation"

  Scenario: Choose new current jurisdiction
  	Given I am a standard user
  	And there are jurisdictions titled Middlesex, Laconia
  	And I have no current jurisdiction
  	And I go to the home page
		Then I should see "Choose Your Jurisdiction:" within "h2"
  	When choose jurisdiction "Middlesex"
  	Then I should see "Middlesex" within "#user-navigation"
  	
  	
  
  
 