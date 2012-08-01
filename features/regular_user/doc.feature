Feature: Documentation Generation/View
  In order to see generated documentationmaintain security of protected data
  Anyone
  Should be able to see a list of documentation
  
  Scenario: View list
    When I enter url "/doc"
    Then I should see "Instructions for CSV Generation"

  Scenario: District Upload
    When I enter url "/doc"
    And I follow "Instructions for CSV Generation"
    Then I should see "examples.csv"

  Scenario: Example CSV
    When I enter url "/doc/district_upload/examples"
    Then I should see "Alternate Files"
