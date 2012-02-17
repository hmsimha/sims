class Interventions::DefinitionsController < ApplicationController
  include PopulateInterventionDropdowns

  def index
    populate_goals
  end

  def create
    respond_to do |format|
      format.html {redirect_to new_intervention_url(:goal_id => params[:goal_id], :objective_id => params[:objective_id],
                                    :category_id => params[:category_id], :definition_id => params[:intervention_definition][:id],
                                                   :custom_intervention => params[:custom_intervention] )}
      format.js {
        populate_intervention
      }
    end
  end
end
