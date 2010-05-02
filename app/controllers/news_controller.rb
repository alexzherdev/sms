class NewsController < ApplicationController
  def index
    @comment = Comment.new
    @news = News.paginate :per_page => 5, :page => params[:page] || 1
  end
  
  def new
    @news = News.new
  end
  
  def create
    @news = News.new params[:news].merge(:author_id => current_user.id)
    
    process_file_uploads(@news)
    
    if @news.save
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
      process_file_uploads(@news)
      @news.save
      redirect_to :action => "index"
    else
      render :action => "edit"
    end
  end
  
  def destroy_attachment
    @attachment = Attachment.find params[:id]
    @att_id = @attachment.id
    @attachment.destroy
  end
  
  def add_comment
    @comment = Comment.new params[:comment].merge(:user_id => current_user.id)
    @comment.save
    render :action => "add_comment.rjs"
  end

  protected
  
  def process_file_uploads(news)
    (params[:attachment] || {}).each do |k, v|
      news.attachments.build(:data => v)
    end
  end
  
end
