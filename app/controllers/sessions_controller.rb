class SessionsController < ApplicationController
  def new
  end

  def create
    para = params[:email]
    if !params[:email].include? "@"
      para = para + "@nilpeter.com"
    end
    Rails.logger.info "API authentication: #{para}"
    user = User.find_by_email(para)

    if user && user.authenticate(params[:password])
#      session[:user_id] = user.id
      if params[:remember_me]
       cookies.permanent[:auth_token] = user.auth_token
      else
       cookies[:auth_token] = user.auth_token
      end
      if user.role_id == 3
        redirect_to(:controller => "admin", notice: "Logged in!")
      else
        redirect_to root_url, notice: "Logged in!"
      end
    else
      redirect_to login_url, notice: "Email or password is invalid."
    end
  end

  def destroy
#    session[:user_id] = nil
    cookies.delete(:auth_token)
    redirect_to root_url, notice: "Logged out!"
  end
end
