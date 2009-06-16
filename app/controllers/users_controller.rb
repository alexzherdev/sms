class UsersController < ApplicationController
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end
  
  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_url
    else
      render :action => :new
    end
  end

  def edit
  end
  
  def update
  end
  
end
