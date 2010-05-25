@elections
Feature: Manage Elections
  In order manage elections
  As a public user
  I want to view elections

  Scenario: Show the list of Elections to a public user
    Given I am a public user
    And I have elections titled Election 1, Election 2
    When I go to the list of elections
    Then I should see "Election 1"
    And I should see "Election 2"
    And I should see "Show"
    And I should see "List"
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

  Scenario: Show the elections
    Given I am logged in as one of the following users
    | email          | password    | role      |
    | curly@foo.com  | mypassword  | public    | 
    | larry@foo.com  | mypassword  | standard  | 
    | moe@foo.com    | mypassword  | root      | 
    
  Scenario: Show the elections for roles
    Given Users with the following roles
    | role      |
    | public    | 
    | standard  | 
    | root      | 


