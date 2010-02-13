class TeacherSubjectsController < ApplicationController
  def index
    @teacher_subjects = TeacherSubject.all
    @subjects = Subject.all
    @student_groups = StudentGroup.all
    @teachers = Teacher.all
  end
  
  def create
    @teacher_subject = TeacherSubject.create params[:teacher_subject]
    render :action => "create.rjs"
  end
  
  def destroy
    TeacherSubject.destroy params[:ids]
    render :nothing => true
  end
end
