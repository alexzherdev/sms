class SearchController < ApplicationController
  PER_PAGE = 10
  def index
    @query = params[:search][:query]

    options = { :page => params[:page], :per_page => PER_PAGE }

    respond_to do |format|
      format.html do
        @students = Student.search @query, options
        @news = News.search @query, options.merge(:order => :created_at, :sort_mode => :desc)
        @teachers = Teacher.search @query, options
      end
      
      format.js do
        @type = params[:type].constantize
        options.merge!(:order => :created_at, :sort_mode => :desc) if @type == News
        @models = @type.search @query, options
        render :action => "update.rjs"
      end
    end
    
  end
end
