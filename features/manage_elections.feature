@elections
Feature: Manage Elections
  In order manage elections
  As a user
  I want to view or manage elections

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

  Scenario: Show an Election to a public user
    Given I am a public user
    And I have election titled Election 1
    When I go to the list of elections
    Then I should see "Election 1"
    When I follow "Show"
    Then I should be on the show election 1 page
    Then I should see "List"
    Then I should not see "New" 
    Then I should not see "Edit"
    Then I should not see "Delete"
    

  @allow-rescue  
  Scenario: Restrict public users from creating an Election.
    Given I am a public user
    And I go to the new election page
    Then I should see "Access Denied"
    # And I should be on the home page

  @allow-rescue  
  Scenario: Restrict public users from deleting an Election.
    Given I am a public user
    And I go to the new election page
    Then I should see "Access Denied"
    # And I should be on the home page

    
  Scenario: Show the list of Elections to a standard user
    Given I am a standard user
    And I have elections titled Election 1, Election 2
    When I go to the list of elections
    Then I should see "Election 1"
    And I should see "Election 2"
    And I should see "Show"
    And I should see "List"
    And I should see "Edit"
    And I should see "Delete"
    And I should see "New"


