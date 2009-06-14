class TeamConsultationsController < ApplicationController
  # GET /team_consultations
  # GET /team_consultations.xml
  def index
    @team_consultations = TeamConsultation.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @team_consultations }
    end
  end

  # GET /team_consultations/1
  # GET /team_consultations/1.xml
  def show
    @team_consultation = TeamConsultation.find(params[:id])

    respond_to do |format|
      format.js
      format.html # show.html.erb
      format.xml  { render :xml => @team_consultation }
    end
  end

  # GET /team_consultations/new
  # GET /team_consultations/new.xml
  def new
    @team_consultation = TeamConsultation.new
    @team_consultation.build_consultation_form if @team_consultation.consultation_form.blank?
    @recipients = current_school.team_schedulers

    respond_to do |format|
      format.js
      format.html # new.html.erb
      format.xml  { render :xml => @team_consultation }
    end
  end

  # GET /team_consultations/1/edit
  def edit
    @team_consultation = TeamConsultation.find(params[:id])
  end

  # POST /team_consultations
  # POST /team_consultations.xml
  def create
    params[:team_consultation] ||= {}
    params[:team_consultation].merge!(:student_id => current_student_id, :requestor_id => current_user_id)
    @team_consultation = TeamConsultation.new(params[:team_consultation])

    respond_to do |format|
      if @team_consultation.save
        
        msg="<p>The concern note has been sent to #{@team_consultation.recipient}.</p>  <p>A discussion about this student will occur at an upcoming team meeting.</p>"
        
        format.js { flash.now[:notice] = msg}
        format.html { flash[:notice]=msg; redirect_to(current_student) }
        format.xml  { render :xml => @team_consultation, :status => :created, :location => @team_consultation }
      else
        @recipients = current_school.team_schedulers
        format.js { render :action => "new" }
        format.html { render :action => "new" }
        format.xml  { render :xml => @team_consultation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /team_consultations/1
  # PUT /team_consultations/1.xml
  def update
    @team_consultation = TeamConsultation.find(params[:id])

    respond_to do |format|
      if @team_consultation.update_attributes(params[:team_consultation])
        flash[:notice] = 'TeamConsultation was successfully updated.'
        format.html { redirect_to(@team_consultation) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @team_consultation.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /team_consultations/1
  # DELETE /team_consultations/1.xml
  def destroy
    @team_consultation = TeamConsultation.find(params[:id])
    @team_consultation.destroy

    respond_to do |format|
      format.html { redirect_to(team_consultations_url) }
      format.xml  { head :ok }
    end
  end
end