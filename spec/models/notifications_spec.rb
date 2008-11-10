require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require 'test/unit'
require 'spec'

describe Notifications do
  def test_principal_override_request
    @expected.subject = 'Notifications#principal_override_request'
    @expected.body    = read_fixture('principal_override_request')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_principal_override_request(@expected.date).encoded
  end

  def test_principal_override_response
    @expected.subject = 'Notifications#principal_override_response'
    @expected.body    = read_fixture('principal_override_response')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_principal_override_response(@expected.date).encoded
  end

  def test_intervention_starting
    @expected.subject = 'Notifications#intervention_starting'
    @expected.body    = read_fixture('intervention_starting')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_intervention_starting(@expected.date).encoded
  end

  def test_intervention_ending_reminder
    @expected.subject = 'Notifications#intervention_ending_reminder'
    @expected.body    = read_fixture('intervention_ending_reminder')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_intervention_ending_reminder(@expected.date).encoded
  end

  def test_intervention_reminder
    @expected.subject = 'Notifications#intervention_reminder'
    @expected.body    = read_fixture('intervention_reminder')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_intervention_reminder(@expected.date).encoded
  end

  def test_intervention_participant_added
    @expected.subject = 'Notifications#intervention_participant_added'
    @expected.body    = read_fixture('intervention_participant_added')
    @expected.date    = Time.now

    assert_equal @expected.encoded, Notifications.create_intervention_participant_added(@expected.date).encoded
  end

end
