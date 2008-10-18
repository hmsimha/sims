class StudentsController < ApplicationController
	before_filter :enforce_session_selections, :except => [:index, :select, :search, :new, :create]

  # GET /students
  # GET /students.xml
  def index
		# enrollments = School.find(session[:school_id]).enrollments(:include=>:students)
		# params[:students] ||= {}
		# selected_grade = params[:students][:grade]
		# if selected_grade and selected_grade != '*'
		# enrollments = enrollments.select{|e| e.grade == selected_grade}
		# end

		# @students = enrollments
		@students = current_school.enrollments.search(session[:search])

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @students }
    end
  end

  def select
    # add selected students to session redirect to show
    
    #need to make sure user has access to these
    session[:selected_students]=params[:id]
    if session[:selected_students].blank?
      flash[:notice]='No students selected'
      redirect_to students_url
    else
      session[:selected_student]=session[:selected_students].first
      redirect_to student_url(session[:selected_student])
    end
  end
  
  def search
		if request.get?
			@grades = current_school.enrollments.collect(&:grade).uniq
			@grades.unshift("*")
		else
			# puts params.inspect
			selected_grade = params['students']['grade']
			selected_last_name = params['students']['last_name']

			session[:search] ||= {}
			session[:search][:grade] = selected_grade
			session[:search][:last_name] = selected_last_name

			redirect_to students_url
		end
  end

  # GET /students/1
  # GET /students/1.xml
  def show
    @student = current_school.students.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @student }
    end
  end

  # GET /students/new
  # GET /students/new.xml
  def new
    @student = current_school.students.build

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @student }
    end
  end

  # GET /students/1/edit
  def edit
    @student = current_schools.students.find(params[:id])
  end

  # POST /students
  # POST /students.xml
  def create
    @student = current_schools.students.build(params[:student])

    respond_to do |format|
      if @student.save
        flash[:notice] = 'Student was successfully created.'
        format.html { redirect_to(@student) }
        format.xml  { render :xml => @student, :status => :created, :location => @student }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @student.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /students/1
  # PUT /students/1.xml
  def update
    @student = current_school.students.find(params[:id])

    respond_to do |format|
      if @student.update_attributes(params[:student])
        flash[:notice] = 'Student was successfully updated.'
        format.html { redirect_to(@student) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @student.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /students/1
  # DELETE /students/1.xml
  def destroy
    @student = current_school.students.find(params[:id])
    @student.destroy

    respond_to do |format|
      format.html { redirect_to(students_url) }
      format.xml  { head :ok }
    end
  end


  private
  def enforce_session_selections
    return true unless params[:id] 
		# raise "I'm here" if selected_students_ids.nil?
    if selected_students_ids and selected_students_ids.include?(params[:id])
      session[:selected_student]=params[:id]
      return true
    else
      flash[:notice]='Student not selected'
      redirect_to students_url and return false
    end
  end

end
