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

  # Pretty decent pickle examples, see ttv_pickle_example for more info

  @root_user    
  Scenario: Allow root users the remove a user's root role
    Given I am a root user
    And a user: "fred" exists with email: "fred@bar.com"
    And a user_role: "root" exists with name: "root", user: user "fred"
    And a user_role: "standard_not_used" exists with name: "standard"
    Then the user_role: "root" should be one of user: "fred"'s roles
    Then the user_role: "standard_not_used" should not be one of user: "fred"'s roles
    When I go to the user: "fred"'s edit page
    Then the "Email" field should contain "fred@bar.com"
    And the "Root" checkbox should be checked
    And the "Standard" checkbox should not be checked
    And I uncheck "Root"
    And I press "Save"
    Then a user should exist with email: "fred@bar.com"
    Then I should not have a user with email: "fred@bar.com" and role: "role"
    Then I should not have a user with email: "fred@bar.com" and role: "standard"
    # NOTE: this doesn't work cuz the user role created no longer exists, wierd pickle bug?
    #Then the user_role: "root" should not be one of user: "fred"'s roles
    Then the user: "fred" should have 0 roles
    Then the user_role: "standard_not_used" should not be one of user: "fred"'s roles

  Scenario: Allow root users the remove a user's standard role
    Given I am a root user
    And a user: "fred" exists with email: "fred@bar.com"
    And a user_role: "root_not_used" exists with name: "root"
    And a user_role: "standard_used" exists with name: "standard", user: user "fred"
    Then the user_role: "standard_used" should be one of user: "fred"'s roles
    Then the user_role: "root_not_used" should not be one of user: "fred"'s roles
    When I go to the user: "fred"'s edit page
    Then the "Email" field should contain "fred@bar.com"
    And the "Root" checkbox should not be checked
    And the "Standard" checkbox should be checked
    And I uncheck "Standard"
    And I press "Save"
    Then I should not have a user with email: "fred@bar.com" and role: "role"
    Then I should not have a user with email: "fred@bar.com" and role: "standard"


  Scenario: Allow root users the remove a all of a user's roles
    Given I am a root user
    And a user: "fred" exists with email: "fred@bar.com"
    And a user_role: "root_used" exists with name: "root", user: user "fred"
    And a user_role: "standard_used" exists with name: "standard", user: user "fred"
    Then the user_role: "standard_used" should be one of user: "fred"'s roles
    Then the user_role: "root_used" should be one of user: "fred"'s roles
    When I go to the user: "fred"'s edit page
    Then the "Email" field should contain "fred@bar.com"
    And the "Root" checkbox should be checked
    And the "Standard" checkbox should be checked
    When I uncheck "Root"
    And I uncheck "Standard"
    And I press "Save"
    Then I should not have a user with email: "fred@bar.com" and role: "role"
    Then I should not have a user with email: "fred@bar.com" and role: "standard"

  @root_user    
  Scenario: Allow root users the view a root user
    # logged in as a root user
    Given I am a root user
    And a user: "fred" exists with email: "fred@bar.com"
    And a user_role: "root" exists with name: "root", user: user "fred"
    And a user_role: "standard_not_used" exists with name: "standard"
    When I go to the users page
    Then I should see "fred@bar.com" in the second row
    Then I should see "root" in the second row
    Then I should not see "standard" in the second row

  @root_user    
  Scenario: Allow root users the view a user that is a root and standard user
    # logged in as a root user
    Given I am a root user
    And a user: "fred" exists with email: "fred@bar.com"
    And a user_role: "root" exists with name: "root", user: user "fred"
    And a user_role: "standard_not_used" exists with name: "standard", user: user "fred"
    When I go to the users page
    Then I should see "fred@bar.com" in the second row
    Then I should see "root" in the second row
    Then I should see "standard" in the second row


  @root_user    
  Scenario: Allow root users the view a user that has no roles
    # logged in as a root user
    Given I am a root user
    And a user: "fred" exists with email: "fred@bar.com"
    When I go to the users page
    Then I should see "fred@bar.com" in the second row
    And I should not see "root" in the second row
    And I should not see "standard" in the second row
    And I should see "No Roles"