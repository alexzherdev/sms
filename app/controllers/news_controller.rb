class NewsController < ApplicationController
  def index
    @news = News.paginate :per_page => 5, :page => params[:page] || 1
  end
  
  def new
    @news = News.new
  end
  
  def create
    @news = News.create params[:news].merge(:author_id => current_user.id)
    if @news.valid?
      redirect_to root_url
    else
      render :action => "new"
    end
  end
  
  def destroy
    @news = News.find params[:id]
    @news.destroy
    render :action => "destroy.rjs"
  end
  
  def edit
    @news = News.find params[:id]
  end
  
  def update
    @news = News.find params[:id]
    if @news.update_attributes params[:news]
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
end
