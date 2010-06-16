Feature: Manage Users
  In order to allow users to use the applicaton
  As a user 
  I want to be able to manage users.

  @allow-rescue @public_user
  Scenario: Restrict public users from viewing users
    Given I am a public user
    And I go to the users page
    Then I should see "Access Denied"
    And I should be on the home page

  @allow-rescue @public_user
  Scenario: Restrict public users from editing users
    Given I am a public user
    And an user exists with email: "foo@bar.com"
    And I go to the user's edit page
    Then user should exist with email: "foo@bar.com"
    Then I should see "Access Denied"
    And I should be on the home page
  
  @allow-rescue @public_user
  Scenario: Restrict public users from updating users
    Given I am a public user
    And an user exists with email: "foo@bar.com"
    And I update the user with email: "foo@bar.com"
    Then user should exist with email: "foo@bar.com"
    And I should be on the home page
    Then I should see "Access Denied"
    And I should be on the home page

  @allow-rescue @public_user
  Scenario: Restrict public users from deleting users
    Given I am a public user
    And an user exists with email: "foo@bar.com"
    And I delete the user with email: "foo@bar.com"
    Then user should exist with email: "foo@bar.com"
    Then I should see "Access Denied"
    And I should be on the home page

  @public_user
  Scenario: Allow public users the ability to register a new user
    Given I am a public user
    And I go to the new user page
    Then I should not see "Access Denied"
    And I should see "Register with TrustTheVote"
    When I fill in "Email" with "foo@example.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Submit"
    Then a user should exist with email: "foo@example.com"
    And I should be on the home page
    And I should see "foo@example.com" within "#user-navigation"
    And I should see "Edit profile" within "#user-navigation"

  @root_user
  Scenario: Allow root users to view users
    Given I am a root user
    And an user exists with email: "foo@bar.com"
    And I go to the users page
    Then I should see "foo@bar.com"
    And I should be on the users page
    
    
    



