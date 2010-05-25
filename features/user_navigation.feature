@header
Feature: Display Header
  In order to provide a user some context and navigation
  As a user
  I want to see common application header

  Scenario: Show the navigation for a logged in user
    Given I am logged in as one of the following users
    | email          | password    | role      |
    | larry@foo.com  | mypassword  | standard  |      
    | moe@foo.com    | mypassword  | root      | 
    When I go to the home page
    Then I should see "Edit profile" within "#user-navigation"
    And I should see "Logout" within "#user-navigation"
    Then I should see the users email within "#user-navigation"
    Then I should see the users jurisdiction within "#user-navigation"

  Scenario: Show the navigation for a public user
    Given I am not logged in
    When I go to the home page
    Then I should not see "Edit profile" within "#user-navigation"
    Then I should not see "Logout" within "#user-navigation"
    Then I should see "Login" within "#user-navigation"
    Then I should see "Register" within "#user-navigation"
