@elections
Feature: Manage Elections
  In order manage elections
  As a user
  I want to view or manage elections
   
  @public_user
  Scenario: Show the list of Elections to a public user
    Given I am a public user
    And I have elections titled Election 1, Election 2
    When I go to the list of elections
    # should see display name and "Show" in second row
    Then I should see "Election 1" in row "2"
    Then I should see a link "Election 1" in row "2"
    And I should see a link "Show" in row "2"
    # same as above, just a different way to view
    Then I should see "Election 1" within ".table tr:nth-child(2)"
    And I should see "Show" within ".table tr:nth-child(2)"
    # should see display name and "Show" in third row
    And I should see a link "Election 2" in row "3"
    And I should see a link "Show" in row "3"
    And I should see a link "List"
    And I should not see "Edit"
    And I should not see "Delete"
    And I should not see "New"

  @public_user
  Scenario: Show an Election to a public user
    Given I am a public user
    And I have an election titled Election 1
    When I go to the list of elections
    Then I should see "Election 1"
    Then I should see a link "Election 1"
    Then I should see "Election 1" in row "2"
    Then I should see a link "Election 1" in row "2"
    When I follow "Show"
    Then I should be on the show election 1 page
    Then I should see a link "List"
    Then I should not see "New" 
    Then I should not see "Edit"
    Then I should not see "Delete"

  @allow-rescue @public_user
  Scenario: Restrict public users from creating an Election.
    Given I am a public user
    And I go to the new election page
    Then I should see "Access Denied"
    # And I should be on the home page

  @allow-rescue @public_user 
  Scenario: Restrict public users from deleting an Election.
    Given I am a public user
    And I go to the new election page
    Then I should see "Access Denied"
    # And I should be on the home page

  @standard_user 
  Scenario: Show the list of Elections to a standard user
    Given I am a standard user
    And I have elections titled Election 1, Election 2
    When I go to the list of elections
    Then I should see a link "Election 1" in row "2"
    And I should see a link "Election 2" in row "2"
    And I should see a link "Show" in row "2"
    And I should see a link "List" in row "2"
    And I should see a link "Edit" in row "2"
    And I should see a link "Delete" in row "2"
    And I should see a link "New" in row "2"
  
  @standard_user
  Scenario Outline: Show the list of Elections standard users
    Given I am a standard user
    And I have an election titled "<election_name>"
    When I go to the list of elections
    Then I should see a link "<election_name>" in row "<row_number>"
    And I should see a link "Show" in row "<row_number>"
    And I should see a link "List" in row "<row_number>"
    And I should see a link "Edit" in row "<row_number>"
    And I should see a link "Delete" in row "<row_number>"
    And I should see a link "New" in row "<row_number>"

  Scenarios:
  |  election_name | row_number |
  | Election 1     |   2        |
  | Election again |   2        |

    

