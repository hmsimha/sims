require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AllControllers do
  describe 'names class method' do
    # NOTE: The names should be generated dynamically
    # For now, I'm just testing that the correct list of names are returned,
    # combined with the knowledge that the code is written to behave dynamically.
    # If you want to change this test to prove that the code is dynamic, be my guest...
    it 'should list all controller names' do
      # For now I'm testing this is strictly equal.
      # Once we trust it, we could use subset? instead to keep it from breaking ALL the time...
      static_list = %w{ application
        checklist_builder/answers checklist_builder/checklists checklist_builder/elements checklist_builder/questions
        checklists 
        cico cico_school_days cico_settings
        consultation_form_requests consultation_forms
        custom_flags district/flag_categories district/schools district/students district/users districts doc
        file flag_descriptions grouped_progress_entries
        groups/assignments groups/students groups/users groups
        help ignore_flags
        intervention_builder/categories intervention_builder/goals intervention_builder/interventions intervention_builder/objectives
        intervention_builder/probes intervention_builder/recommended_monitors
        interventions/categories interventions/comments interventions/definitions interventions/goals interventions/objectives interventions/participants
        interventions/probe_assignments interventions/probes interventions/quicklists
        interventions main news_items
        personal_groups
        principal_overrides quicklist_items recommendations reports
        school_admin
        school_teams
        schools scripted special_user_groups spell_check stats
        student_comments student_searches students
        team_consultations tiers
        unattached_interventions
        users/omniauth_callbacks
        users/passwords
        users/sessions
      }
      AllControllers.names.should ==  static_list
    end
  end
end
