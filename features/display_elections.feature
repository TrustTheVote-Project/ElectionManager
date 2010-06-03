@elections
Feature: Display Elections
  In order to display elections
  As a user
  I want to display elections
   
  @public_user
  Scenario: Show elections to a public user
    Given I am a public user
    And an election exists with display_name: "Election 1"
    And another election exists with display_name: "Election 2"
    When I go to the list page for elections
    Then I should see a link "List"
    And I should see "Election 1" in row 1
    And I should see a link "Election 1" in row 1
    And I should see a link "Election 1" in the first row
    And I should see a link "Show" in the first row
    # same as above, just a different way to view
    And I should see "Election 1" within ".table tr:nth-child(2)"
    And I should see "Show" within ".table tr:nth-child(2)"
    And I should see "Election 2" in the second row
    And I should see a link "Election 2" in the second row
    And I should not see "Edit"
    And I should not see "Delete"
    And I should not see "New"

  @standard_user 
  Scenario: Show the list of Elections to a standard user
    Given I am a standard user
    And the following elections exists
    |display_name|
    | Election 1 |
    | Election 2 |
    When I go to the list page for elections
    And I should see a link "List"
    Then I should see a link "Election 1" in the first row
    And I should see a link "Election 2" in the second row
    And I should see a link "Show" in the second row 
    And I should see a link "Edit" in the second row
    And I should see a link "Delete" in the second row
    And I should see a link "New" in the second row
  
  @standard_user
  Scenario Outline: Show the list of Elections standard users
    Given I am a standard user
    And I have an election with a display name of "<election_name>"     
    When I go to the list page for elections
    Then I should see a link "<election_name>" in row <row_number>
    And I should see a link "Show" in row <row_number>
    And I should see a link "List" in row <row_number>
    And I should see a link "Edit" in row <row_number>
    And I should see a link "Delete" in row <row_number>
    And I should see a link "New" in row <row_number>

  Scenarios:
  |  election_name | row_number |
  | Election 1     |   1        |
  | Election 2     |   1        |


