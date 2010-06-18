Feature: Register Users
  In order to allow users to use the applicaton
  As a public, not logged in user 
  I want to be register a user

  @public_user
  Scenario: Allow public users the ability to register a new user
    Given I am a public user
    #And I go to the register user page
    When I go to the home page
    Then I should see "Register" within "#user-navigation"
    When I follow "Register"
    Then I should not see "Access Denied"
    And I should see "Register with TrustTheVote"
    When I fill in "Email" with "foo@example.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Submit"
    Then a user should exist with email: "foo@example.com"
    And user should have 1 roles
    And I should be on the home page
    And I should see "foo@example.com" within "#user-navigation"
    And I should see "Successfully created a new user" within "#flash .notice"

  @public_user
  Scenario: Don't allow public users the ability to register a new user with another users email
    Given I am a public user
    And an user exists with email: "foo@example.com"
    When I go to the home page
    Then I should see "Register" within "#user-navigation"
    When I follow "Register"
    Then I should not see "Access Denied"
    And I should see "Register with TrustTheVote"
    When I fill in "Email" with "foo@example.com"
    And I fill in "Password" with "password"
    And I fill in "Password confirmation" with "password"
    And I press "Submit"
    Then a user should exist with email: "foo@example.com"
    And I should be on the register user page
    And I should not see "foo@example.com" within "#user-navigation"
    And I should see "Failed to create a new user" within "#flash .error"
    And I should see "Email has already been taken" within "#flash .error"

  @public_user
  Scenario: Don't allow public users the ability to register a user without a password
    Given I am a public user
    When I go to the home page
    Then I should see "Register" within "#user-navigation"
    When I follow "Register"
    And I should see "Register with TrustTheVote"
    When I fill in "Email" with "foo@example.com"
    And I press "Submit"
    Then a user should not exist with email: "foo@example.com"
    And I should be on the register user page
    And I should not see "foo@example.com" within "#user-navigation"
    And I should see "Failed to create a new user" within "#flash .error"
    And I should see "Password needs to be 1 chars" within "#flash .error"

  @wip @allow-rescue @public_user
  Scenario: Restrict public users from creating a new user, this is reserved for root users
    #Given I am a public user
    #And I go to the home page
    #And I go to the new user page
    # And I should not see "Register with TrustTheVote"


  @public_user
  Scenario: Prompt public users to create a user account
    Given I am a public user
    When I go to the home page
    Then I should see "You may access public information here without logging in"
    And I should see "click here to register"
    When I follow "here"
    And I should be on the register user page
