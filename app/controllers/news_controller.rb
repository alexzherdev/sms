class NewsController < ApplicationController
  def index
    @news = News.paginate :per_page => 5, :page => params[:page] || 1
  end
  
  def show
    @news = News.find params[:id]
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
    if params[:comment][:parent_type] == "News"
      @comment = Comment.new params[:comment].merge(:user_id => current_user.id)
      unless News.find(params[:comment][:parent_id]).blank?
        @comment.save
        render :action => "add_comment.rjs", :status => 200
      else
        index
        redirect_to :action => "index"
      end
    else
      render :nothing => true, :status => 403
    end
  end

  def edit_comment
    @comment = Comment.find(params[:comment][:id])
    if @comment.editable?(current_user)
      @comment.body = params[:comment][:body]
      @comment.save
      render :action => "edit_comment.rjs", :status => 200
    else
      render :action => "edit_comment.rjs", :status => 403
    end
  end

  def destroy_comment
    @comment = Comment.find(params[:id])
    if !@comment.blank? && @comment.removable?(current_user)
      @comment.destroy
      #render :action => "destroy_comment.rjs"
    else
      index
      redirect_to :action => "index"
    end
  end

  protected
  
  def process_file_uploads(news)
    (params[:attachment] || {}).each do |k, v|
      news.attachments.build(:data => v)
    end
  end
  
end
