class SearchController < ApplicationController
  def index
    @query = params[:search][:query]

    @students = Student.search @query
    @class_rooms = ClassRoom.search @query
    @news = News.search @query
    @subjects = Subject.search @query
    @teachers = Teacher.search @query
  end
end
