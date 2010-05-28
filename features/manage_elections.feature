@elections
Feature: Manage Elections
  In order manage elections
  As a user
  I want to mannage,(create, update or delete), elections
   
  @standard_user 
  Scenario: Allow user to create an election
    Given I am a standard user
    And I have a district set titled "Jurisdiction 1"
    When I go to the list of elections
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
    When I go to the list of elections
    And I follow "New"
    And I fill in "Display Name" with "Election 2"
    And I fill in District Set with the id for district set "Jurisdiction 2"
    And I select "(built-in default Ballot Style Template)" from "Ballot Style Template"
    And I select "(built-in default voting method)" from "Default Voting Method"
    And I press "Save"
    Then I should have an election titled "Election 2"
    Then I should be on the show election "Election 2" page
    
