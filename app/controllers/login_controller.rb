class LoginController < ApplicationController
  include CountryStateDistrict
  skip_before_filter :authenticate, :authorize, :verify_authenticity_token

  #There is a potential for csrf attacks for logout which would be annoying for the user, but not really harmful
  #same for login, but there really would be no reason to trick a user into logging in as someone else.   The tradeoff here is for usability
  #There are often errors from a logout form that get invalidated by a server restart showing an error to the user.   This should eliminate those errors
  layout 'main'
  def login
    dropdowns
    @user=User.new(:username=>params[:username])
    session[:user_id] = nil
    
    if request.post? and current_district
      @user=current_district.users.authenticate(params[:username], params[:password]) || @user
      session[:user_id] = @user.id
      if @user.new_record?
        logger.info "Failed login of #{params[:username]} at #{current_district.name}"
        current_district.logs.create(:body => "Failed login of #{params[:username]}") unless current_district.new_record?
        if @user.token
          flash[:notice] = 'An email has been sent, follow the link to change your password.'
        else
          flash[:notice] = 'Authentication Failure'
        end
      else
        @user.record_successful_login
        session[:district_id]=current_district.id
        current_user = @user
        flash[:notice] = nil if flash[:notice] == 'Authentication Failure'
        redirect_to successful_login_destination and return
      end
    end
    @district = current_district #LH582

  end

  def logout
    oldflash = flash[:notice]
    reset_session_and_district
    dropdowns
    render :action=>:login #the redirect wasn't properly clearing the cookie via the reset_session
  end

  def index
    login
    render :action=>"login"
  end

  def change_password
    reset_session_and_district if params['token'].present?
    @user = current_user

    if @user.new_record? 
      id=params[:id] || (params[:user] && params[:user][:id])
      token = params['token'] || (params[:user] && params['user'][:token])
      @user =  User.find(id, :conditions => ["(passwordhash ='' or passwordhash is null) and (salt ='' or salt is null) and token = ?",token]) #and email_token
      redirect_to logout if @user.blank?
    end

    if request.put?
      if @user.change_password(params['user'])
        flash[:notice] = 'Your password has been changed'
        redirect_to root_url
      end
    end
 end

 
private
  def reset_session_and_district
    reset_session
    current_user = User.new
    session[:district_id]=nil
    
  end

  def successful_login_destination
    return session[:requested_url] if session[:requested_url]
    begin
    if ENABLE_SUBDOMAINS 
      subdomain = current_district.abbrev #and Object.const_defined?('SIMS_DOMAIN') and request.host.include?(Object.const_get('SIMS_DOMAIN'))
    end
    return root_url(:subdomain=>subdomain)
    rescue NameError
    end
      root_url()
  end

  
end


