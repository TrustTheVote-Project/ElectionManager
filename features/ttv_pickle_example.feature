Feature: Manage Users
  In order to restrict access to users
  As a user 
  I want to be able to assign roles to users

  # Pretty decent pickle example
  @root_user    
  Scenario: Allow root users the remove a user's root role
    # I'm logged in as a root user
    # NOTE: this is not a webrat or pickle step definition
    Given I am a root user

    # Create a user, identified by pickle as "fred", whose email attribute is "fred@bar.com"
    And a user: "fred" exists with email: "fred@bar.com"

    # Create a user role, identified by pickle as "root", whose name attribute is "root"
    # and  this "root" role "belongs_to" the user "fred" created in the last step.
    # NOTE: This adds this "root" role to the user fred's has_many association
    And a user_role: "root" exists with name: "root", user: user "fred"

    # Create a user role, identified by pickle as "standard_not_used"
    And a user_role: "standard_not_used" exists with name: "standard"

    # Just my feeble user step definitions, probably don't need anymoe
    Then I should have a user with email: "fred@bar.com" and role: "root"
    Then I should not have a user with email: "fred@bar.com" and role: "standard"

    # Make sure that the "root" role is on user fred's roles
    Then the user_role: "root" should be one of user: "fred"'s roles

    # Make sure that the "standard_not_used" role is not one user fred's roles
    Then the user_role: "standard_not_used" should not be one of user: "fred"'s roles



