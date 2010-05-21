class SearchController < ApplicationController
  PER_PAGE = 10
  def index
    @query = params[:search][:query]

    args = [@query, { :page => params[:page], :per_page => PER_PAGE }]
    
    respond_to do |format|
      format.html do
        @students = Student.search *args
        @class_rooms = ClassRoom.search *args
        @news = News.search *args
        @subjects = Subject.search *args
        @teachers = Teacher.search *args
      end
      
      format.js do
        @type = params[:type].constantize
        @models = @type.search *args
        render :action => "update.rjs"
      end
    end
    
  end
end
