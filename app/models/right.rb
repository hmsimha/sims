class Right

RIGHTS={
  "news_admin"=>["news_items"],
  "regular_user"=>["custom_flags",
    "recommendations",
    "interventions/quicklists",
    "interventions/participants",
    "interventions/categories",
    "consultation_forms",
    "interventions/comments",
    "interventions",
    "interventions/probes",
    "interventions/objectives",
    "team_consultations",
    "custom_probes",
    "principal_overrides",
    "interventions/goals",
    "reports",
    "custom_interventions",
    "interventions/definitions",
    "interventions/probe_assignments",
    "schools",
    "consultation_form_requests",
    "checklists",
    "students",
    "student_comments",
    "student_searches",
    "grouped_progress_entries",
    "unattached_interventions",
    "personal_groups",
    "ignore_flags",],
  "content_admin"=>["intervention_builder/recommended_monitors",
      "intervention_builder/goals",
      "checklist_builder/elements",
      "intervention_builder/probes",
      "intervention_builder/objectives",
      "checklist_builder/questions",
      "checklist_builder/checklists",
      "intervention_builder/categories",
      "checklist_builder/answers",
      "intervention_builder/interventions",
      "district/flag_categories",
      "reports",
      "tiers",],
 "local_system_administrator"=>["district/users",
   "district/schools",
   "flag_descriptions",
   "districts",
   "district/students"]}

  def self.cache_key
    Digest::MD5.hexdigest(RIGHTS.inspect)
  end

end
