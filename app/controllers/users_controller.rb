class UsersController < ApplicationController
  def index
    @users = User.all
    @roles = Role.all
  end

  def new
    @user = User.new
    render :partial => "form", :locals => { :url => users_path, :method => "POST" }
  end
  
  def create
    @user = User.create params[:user]
    render :action => "create.rjs", :status => @user.valid? ? 200 : 403
  end

  def edit
    @user = User.find params[:id]
    render :partial => "form", :locals => { :url => user_path(@user), :method => "PUT" }
  end
  
  def update
    @user = User.find params[:id]
    @user.update_attributes params[:user]
    render :action => "update.rjs", :status => @user.valid? ? 200 : 403
  end
end
