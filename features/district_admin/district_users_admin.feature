Feature: User Maintenance
  In order to create/maintain users
  A SIMS district admin
  Should be able to create edit and remove users

  Scenario: Nondistrict admin should not see useradministration panel
    Given common data
    When I start at the school selection page
    Then I should not see "Add/Remove Users"

  Scenario: District admin should be able to add/create Users
    Given I am a district admin
    And I start at the home page
    Then I follow "Add/Remove Users"
    Then I follow "New user"
    Then I fill in "Username" with "cuke_user"
    Then I fill in "First name" with "Cuke"
    Then I fill in "Middle name" with "Umber"
    Then I fill in "Last name" with "AAUser"
    And I fill in "Suffix" with "IV"
    Then I press "Create"
    Then I should see "Password can't be blank"
    Then I fill in "Password" with "cuke"
    Then I press "Create"
    Then I should see "Password doesn't match confirmation"
    Then I fill in "Password" with "cuke"
    Then I fill in "Password confirmation" with "cuke"
    Then I press "Create"
    And I should see "Cuke U. AAUser IV"
    When I follow "Edit"
    Then the "Middle" field should contain "Umber"
    And the "Suffix" field should contain "IV"
    Then I fill in "Username" with "cuke_user"
    Then I press "Update"
    Then I follow "Edit"
    Then I fill in "Username" with "unused_username_cuke"
    Then I press "Update"
    Then I should see "unused_username_cuke"


  Scenario: District admin should not see staff assignments section if none have been added
    Given I am a district admin
    And I start at the home page
    Then I follow "Add/Remove Users"
    When I follow "Edit"
    Then I should not see "Staff Assignments"

  Scenario: District admin should see staff assignments section if some have been added
    Given I am a district admin
    And the other district admin is gone
    And I am assigned to "Test School"
    And I start at the home page
    Then I follow "Add/Remove Users"
    When I follow "Edit"
    Then I should see "Staff Assignments"
#submit existing
    When I press "Update"
    Then I should see "was successfully updated"
    And I should not see "All staff assignments have been removed, upload a new staff_assignments.csv if you want to use this feature."
#add one
    And PENDING

#delete one
#delete last
  Scenario: District admin should see staff assignments section if some have been added
    Given I am a district admin
    And the other district admin is gone
    And I am assigned to "Test School"
    And I start at the home page
    Then I follow "Add/Remove Users"
    When I follow "Edit"
    And I fill in "Password" with "Password"
    And I fill in "Password confirmation" with "Password"
    And I press "Update"
    Then I should not see "Please Login"
    And I should see "was successfully updated"

#
