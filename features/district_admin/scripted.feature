Feature: Scrited Interaction with SIMS
  In order to allow automated interaction with SIMS
  A SIMS DISTRICT ADMIN
  Should be able to upload and download a file using curl

  Scenario: Automated Intervention
    Given a user "automated_intervention"
    And a student with district_student_id "cuke123"
    And an intervention_definition with id "99876"
    And a probe_definition with id "99876"
    And a clear email queue
    When I log in with basic auth as "automated_intervention" with password "e"
    And I enter url "/scripted/automated_intervention" with abbrev
    Then I should see "Upload a file with the following headers"
    And I should see "You can also automate this using curl"
    And I should see "intervention_definition_id"
    And I should see "Have the content admin navigate to the intervention in the content builder. It is the number at the end of the url"
    When I attach the file "test/csv/automated_intervention/sample.csv" to "upload_file"
    And I press "Submit"
    Then "automated_intervention@example.com" should receive an email
    When they open the email
    Then they should see "4 interventions added" in the email body

