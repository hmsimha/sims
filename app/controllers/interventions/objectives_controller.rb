class Interventions::ObjectivesController < ApplicationController
  include PopulateInterventionDropdowns

  def index
    populate_goals
  end

   def select
    respond_to do |format|
      format.html do
        if params[:objective_definition][:id].present?
          redirect_to interventions_categories_url(params[:goal_id],params[:objective_definition][:id],
                                                  :custom_intervention => params[:custom_intervention])
        else
          redirect_to :back
          # interventions_objectives_url(params[:goal_id],params[:objective_id])
        end
      end
      format.js {
        populate_categories
      }
    end
  end

end
