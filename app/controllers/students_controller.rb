class StudentsController < ApplicationController
  def index
    @students = Student.all
    @student_groups = StudentGroup.all
  end

  def new
    @student = Student.new
    render :partial => "form", :locals => { :url => students_path, :method => "POST" }
  end
  
  def create
    @student = Student.new params[:student]
    @student.save
    render :action => "create.rjs", :status => @student.valid? ? 200 : 403
  end
  
  def edit
    @student = Student.find params[:id]
    render :partial => "form", :locals => { :url => student_path(@student), :method => "PUT" }
  end
  
  def update
    @student = Student.find params[:id]
    @student.update_attributes params[:student]
    render :action => "update.rjs", :status => @student.valid? ? 200 : 403
  end
  
  def destroy
    @student = Student.find params[:id]
    @student.destroy
    redirect_to students_url
  end
  
  def import
    importer = StudentsImporter.new params[:file].read
    students = importer.parse
    Student.create students
    redirect_to students_url
  end
end
