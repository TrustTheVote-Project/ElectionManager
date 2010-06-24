Feature: Manage Users
  In order to restrict access to users
  As a user 
  I want to be able to assign roles to users

  @root_user    
  Scenario: Allow root users the ability to create new user without a role
    # logged in as a root user
    Given I am a root user
    And I go to the new user page
    # new users have no roles by default
    Then I should see "Root" 
    And I should see "Standard"
    And the "Root" checkbox should not be checked
    And the "Standard" checkbox should not be checked
    When I fill in "Email" with "bar@foo.com"
    And I fill in "Password" with "password1"
    And I fill in "Password Confirmation" with "password1"
    When I press "Save"
    Then user should exist with email: "bar@foo.com"
    And I should not have a user with email: "bar@foo.com" and role: "root"
    Then I should not have a user with email: "bar@foo.com" and role: "standard"
    And I should be on the home page
    And I should see "Successfully created a new user" within "#flash .notice"

  @root_user    
  Scenario: Allow root users the ability to create new root users
    # logged in as a root user
    Given I am a root user
    And I go to the new user page
    When I fill in "Email" with "bar@foo.com"
    And I fill in "Password" with "password1"
    And I fill in "Password Confirmation" with "password1"
    And I check "Root"
    When I press "Save"
    Then I should have a user with email: "bar@foo.com" and role: "root"
    Then I should not have a user with email: "bar@foo.com" and role: "standard"
    And I should be on the home page
    And I should see "Successfully created a new user" within "#flash .notice"

  @root_user    
  Scenario: Allow root users the ability to create a new standard  user
    Given I am a root user
    And I go to the new user page
    When I fill in "Email" with "bar@foo.com"
    And I fill in "Password" with "password1"
    And I fill in "Password Confirmation" with "password1"
    And I check "Standard"
    When I press "Save"
    Then I should have a user with email: "bar@foo.com" and role: "standard"
    Then I should not have a user with email: "bar@foo.com" and role: "root"
    And I should be on the home page
    And I should see "Successfully created a new user" within "#flash .notice"

  @root_user    
  Scenario: Allow root users the ability to create a new user with a standard and root role
    Given I am a root user
    And I go to the new user page
    When I fill in "Email" with "bar@foo.com"
    And I fill in "Password" with "password1"
    And I fill in "Password Confirmation" with "password1"
    And I check "Standard"
    And I check "Root"
    When I press "Save"
    Then I should have a user with email: "bar@foo.com" and role: "standard"
    Then I should have a user with email: "bar@foo.com" and role: "root"
    And I should be on the home page
    And I should see "Successfully created a new user" within "#flash .notice"

