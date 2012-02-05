Feature: School Maintenance
  In order to create/maintain schools
  A SIMS district admin
  Should be able to create edit and remove schools school

  Scenario: Nondistrict admin should not see school administration panel
    Given common data
    When I start at the school selection page
    Then I should not see "Add/Remove Schools"

  Scenario: District admin should be able to add/create schools
    Given I am a district admin
    And I start at the home page
    Then I follow "Add/Remove Schools"
    Then I follow "New School"
    Then I fill in "Name" with "Cucumber Elementary"
    Then I press "Create"
    Then I should see "Cucumber Elementary"
    Then I follow "New School"
    Then I fill in "Name" with "Cucumber Elementary"
    Then I press "Create"
    Then I should see "Name has already been taken"
    Then I fill in "Name" with "Cucumber High"
    Then I press "Create"
    Then I follow "Edit"
    Then I fill in "Name" with "Cucumber High"
    Then I press "Update"
    Then I should see "Name has already been taken"
    Then I fill in "Name" with "Cucumber Middle"
    Then I press "Update"
    Then I should see "Cucumber Middle"
