@navigation
Feature: Display Header
  In order to provide a user some context and navigation
  As a user
  I want to see common application header
  
  @public_user
  Scenario: Show the navigation for a public user
    Given I am not logged in
    When I go to the home page
    Then I should not see "Edit profile" within "#user-navigation"
    Then I should not see "Logout" within "#user-navigation"
    Then I should see "Login" within "#user-navigation"
    Then I should see "Register" within "#user-navigation"

  @standard_user
  Scenario Outline: Show the navigation for a logged in user
    Given I am a user with a role of "<role>" and an email "<email>"
    When I go to the home page
    Then I should see "Edit profile" within "#user-navigation"
    And I should see "Logout" within "#user-navigation"
    And I should see "<email>" within "#user-navigation"
#    Then I should see the users jurisdiction within "#user-navigation"

  Examples:
    | role           | email              |
    | standard       | larry@foo.com      |
    | root           | moe@foo.com        |

