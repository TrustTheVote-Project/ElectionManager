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

  @root_user

  Scenario: Allow the root user the ability to edit his profile
    Given I login as a user with email: "foo@bar.com" and role: "root"
    And I go to the home page
    Then I should have a user with email: "foo@bar.com" and role: "root"
    And I should see "foo@bar.com" within "#user-navigation"
    And I should see "Edit profile" within "#user-navigation"
    Given I follow "Edit profile"
    Then I should be on the edit user page
    And the "Email" field should contain "foo@bar.com"


  
  @public_user @standard_user 
  Scenario Outline: Hide admin functions from non root users
    Given I am a user with a role of "<role>" and an email "<email>"
    When I go to the home page
    Then I should not see "View all users"
    Then I should not see "View all style templates"
    Then I should not see "View all ballot styles"
    Then I should not see "Maintainenace Tasks"
  Examples:
    | role           | email              |
    | standard       | larry@foo.com      |
    | public         | curley@foo.com     |

  @root_user
  Scenario: Show admin functions to root users
    Given I am a user with a role of "root" and an email "moe@example.com"
    When I go to the home page
    Then I should see "View all users"
    Then I should see "View all style templates" 
    Then I should see "View all ballot styles"
    Then I should see "Maintenance Tasks"
