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
    @user = User.new params[:user]
    @user.save
    render :action => "create.rjs", :status => @user.valid? ? 200 : 403
  end

  def edit
    @user = User.find params[:id]
    render :partial => "form", :locals => { :url => user_path(@user), :method => "PUT" }
  end
  
  def update
    @user = User.find params[:id]
    if @user.update_attributes params[:user]
      render :text => ""
    else
      render :text => "", :status => 403
    end
  end
end
