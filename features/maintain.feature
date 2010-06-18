Feature: Maintain application
  In order to maintain the application
  As a root user
  I want to be able to setup and configure the application

  @root_user
  Scenario: Allow root users the ability to maintain the application
  Given I am a root user
  And I go to the home page
  Then I should see "Maintainenace Tasks" within "#sidebar"
  When I follow "Maintainenace Tasks"
  Then I should be on the maintain page

  @public_user
  Scenario: Restrict public users from maintaining the application
  Given I am a public user
  And I go to the home page
  Then I should not see "Maintainenace Tasks"

  @public_user
  Scenario: Restrict public users from maintaining the application
  Given I am a public user
  And I go to the home page
  Then I should not see "Maintainenace Tasks"

  # TODO: 
  @wip  @public_user
  Scenario: Restrict public users from importing a file
  Given I am a public user
  And I go to the home page
  Then I should not see "Maintainenace Tasks"
  # try to directly access the MaintainController's import_file action
  When I go to the maintainers import_file page
  Then I should see "Access Denied"
  And I should be on the home page

  # TODO: 
  @wip  @public_user
  Scenario: Restrict public users from doing an import batch

  # TODO: 
  @wip  @public_user
  Scenario: Restrict public users from doing an exporting a file

  # TODO: 
  @wip  @standard_user
  Scenario: Restrict standard users from importing a file

  # TODO: 
  @wip  @standard_user
  Scenario: Restrict standard users from doing an import batch

  # TODO: 
  @wip  @standard_user
  Scenario: Restrict standard users from doing an exporting a file


  @standard_user
  Scenario: Restrict standard users from maintaining the application
  Given I am a standard user
  And I go to the home page
  Then I should not see "Maintainenace Tasks"
  