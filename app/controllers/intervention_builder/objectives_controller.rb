class InterventionBuilder::ObjectivesController < ApplicationController
  

  helper_method :move_path
  before_filter(:get_goal_definition)#,:authorize)

  # GET /objective_definitions
  def index
    @objective_definitions = @goal_definition.objective_definitions.find(:all)

    respond_to do |format|
      format.html # index.rhtml
    end
  end

  # GET /objective_definitions/1
  def show

    respond_to do |format|
      format.html # show.rhtml
    end
  end

  # GET /objective_definitions/new
  def new
    @objective_definition = @goal_definition.objective_definitions.build
    @objective_definition.assets.build
  end

  # GET /objective_definitions/1;edit
  def edit
  end

  # POST /objective_definitions
  def create
    @objective_definition = @goal_definition.objective_definitions.build(params[:objective_definition])
    respond_to do |format|
      if @objective_definition.save
        flash[:notice] = 'ObjectiveDefinition was successfully created.'
        format.html { redirect_to intervention_builder_objective_url(@goal_definition,@objective_definition) }
      else
        format.html { render :action => "new" }
      end
    end
  end

  # PUT /objective_definitions/1
  def update

    respond_to do |format|
      if @objective_definition.update_attributes(params[:objective_definition])
        flash[:notice] = 'ObjectiveDefinition was successfully updated.'
        format.html { redirect_to intervention_builder_objective_url(@goal_definition,@objective_definition) }
      else
        format.html { render :action => "edit" }
      end
    end
  end

  # DELETE /objective_definitions/1
  def destroy

    if @objective_definition.intervention_clusters.any?
      flash[:notice]= "Intervention Categories, please remove them first"
    else
      @objective_definition.destroy
    end
    respond_to do |format|
      format.html { redirect_to intervention_builder_objectives_url }
    end
  end

  def disable
    @objective_definition.disable!
    respond_to do |format|
      format.html { redirect_to intervention_builder_objectives_url }
    end
  end


  def move
    @objective_definition = @goal_definition.objective_definitions.find(params[:id])

    if params[:direction]
      @objective_definition.move_higher if params[:direction].to_s == "up"
      @objective_definition.move_lower if params[:direction].to_s == "down"
    end
    respond_to do |format|
      format.html {redirect_to index_url}
      format.js {@objective_definitions=@goal_definition.objective_definitions} 
    end
  end


  private
  def get_goal_definition
    @goal_definition = current_district.goal_definitions.find(params[:goal_id])
    @objective_definition = @goal_definition.objective_definitions.find(params[:id]) if params[:id]
  end
  
  def move_path(item, direction)
    move_intervention_builder_objective_path(:id=>item,:direction=>direction)
  end

end
