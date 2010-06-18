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
  @root_user


  @allow-rescue @public_user
  Scenario: Restrict public users from creating a new user, this is reserved for root users
    #Given I am a public user
    #And I go to the home page
    #And I go to the new user page
    # And I should not see "Register with TrustTheVote"

