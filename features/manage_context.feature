Feature: Manage Context
  In order to maintain my current context
  I want to view my current context

  Scenario: Show "Choose Jurisdiction" when no Jurisdiciton
 	Given I am a standard user
  	And I have no current jurisdiction
        And a district_set exists with display_name: "Jurisdiction 1"
   	Then I should see "no jurisdiction selected" within "#user-navigation"

  @public_user
  Scenario: Choose new current jurisdiction
  	Given I am a standard user
        And a district_set exists with display_name: "Jurisdiction 1"
        And a election exists with district_set: the first district_set
    	And I have no current jurisdiction
  	And I go to the home page
	Then I should see "Choose Your Jurisdiction:" within "h2"
        And a district_set should exist with display_name: "Jurisdiction 1"
        And a election should exist with district_set: the first district_set
        And I should not see "Jurisdiction 1" within "#user-navigation"
        When I follow "Jurisdiction 1"
  	Then I should see "Jurisdiction 1" within "#user-navigation"
