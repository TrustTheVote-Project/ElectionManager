@elections
Feature: Manage Elections
  In order manage elections
  As a user
  I want to mannage,(create, update or delete), elections

  ################ CREATE ###########################

  @allow-rescue @public_user
  Scenario: Restrict public users from creating an Election.
    Given I am a public user
    And I go to the new election page
    Then I should see "Access Denied"
    #And I should be on the home page

  @standard_user 
  Scenario: Allow user to create an election
    Given I am a standard user
    And I have a district set titled "Jurisdiction 1"
    When I go to the list page for elections
    And I follow "New"
    And I fill in "Display Name" with "Election 1"
    And I fill in District Set with the id for district set "Jurisdiction 1"
    And I select "(built-in default Ballot Style Template)" from "Ballot Style Template"
    And I select "(built-in default voting method)" from "Default Voting Method"
    And I press "Save"
    Then I should have an election titled "Election 1"
    Then I should have a district set titled "Jurisdiction 1"
    Then I should be on the show election "Election 1" page
    
  @root_user
  Scenario: Allow root user to create an election
    Given I am a root user
    And I have a district set titled "Jurisdiction 2"
    When I go to the list page for elections
    And I follow "New"
    And I fill in "Display Name" with "Election 2"
    And I fill in District Set with the id for district set "Jurisdiction 2"
    And I select "(built-in default Ballot Style Template)" from "Ballot Style Template"
    And I select "(built-in default voting method)" from "Default Voting Method"
    And I press "Save"
    Then I should have an election titled "Election 2"
    Then I should be on the show election "Election 2" page

  ################ UPDATE ###########################    


  ################ DELETE ###########################    
  @allow-rescue @public_user 
  Scenario: Restrict public users from deleting an Election.
    Given I am a public user
    And no elections exists
    And an election exists with display_name: "Election 1"
    When I delete the election named "Election 1"
    Then I should see "Access Denied"
    And election should exist with display_name: "Election 1"

  @allow-rescue @standard_user
  Scenario: Allow user to delete an election
    Given I am a standard user
    And no elections exists
    And an election exists with display_name: "Election 1"
    When I delete the election named "Election 1"
    Then I should not see "Access Denied"
    And election should not exist with display_name: "Election 1"
    And an election should not exist

  @allow-rescue @rootuser
  Scenario: Allow root user to delete an election
    Given I am a root user
    And no elections exists
    And an election exists with display_name: "Election 1"
    When I delete the election named "Election 1"
    Then I should not see "Access Denied"
    And election should not exist with display_name: "Election 1"
    And an election should not exist

