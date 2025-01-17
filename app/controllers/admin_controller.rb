class AdminController < ApplicationController
  
#  http_basic_authenticate_with :name => "admin", :password => "nilp3ter"
#  before_filter :login
#  before_filter :authenticate
#
#  def authenticate
#    authenticate_or_request_with_http_basic('Administration') do |username, password|
#      username == 'admin' && password == 'password'
##        true
##      else
##        redirect_to '/register/calendar'
##      end
#    end
#  end
  
  before_filter :authorize_admin
 
  
  def index
    @companies = Company.order('name ASC').paginate(:per_page => 25, :page => params[:page])
  end
  
  def create
    @company = Company.create!(params[:company])
    flash[:notice] = "#{@company.name} was successfully created."
    redirect_to(:action => "index")
  end
  
  def edit
    @company = Company.find(params[:id])
  end

  def update
    @company = Company.find(params[:id])
    @company.update_attributes!(params[:company])
    flash[:notice] = "#{@company.name} was successfully updated."
#    redirect_to(:action => "show", :id => @schedule.id)
    redirect_to(:action => "index")
  end
  
  def delete
    @company = Company.find(params[:id])
  end
  
  def destroy
    @company = Company.find(params[:id])
    @company.destroy
    flash[:notice] = "#{@company.name} was successfully deleted."
    redirect_to(:action => "index")
  end

  def users
    @users = User.all
  end

  def reset_password
    @user = User.find(params[:id])
    @role = Role.all
  end
  
  def update_password
    @user = User.find(params[:id])
    @user.update_attributes!(params[:user])
    flash[:notice] = "#{@user.email} was successfully updated."
    redirect_to(:controller => 'admin', :action => "users")
  end
  
  def delete_user
    @user = User.find(params[:id])
    @user.destroy
    flash[:notice] = "#{@user.email} was successfully deleted."
    redirect_to(:controller => 'admin', :action => "users")
  end
  
  def update_user
    @user = User.find(params[:id])
    @user.update_attributes!(params[:user])
    
  end
end
