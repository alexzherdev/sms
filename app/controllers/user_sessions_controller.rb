class UserSessionsController < ApplicationController  
  skip_before_filter :login_required, :except => :destroy
  
  def new
    if current_user
      redirect_to root_url
      return
    end
    @user_session = UserSession.new
  end
  
  def create
    @user_session = UserSession.new params[:user_session]
    if @user_session.save
      redirect_to root_url
    else
      render :action => "new"
    end
  end
  
  def destroy
    @user_session = UserSession.find
    @user_session.destroy
    redirect_to login_url
  end
end
