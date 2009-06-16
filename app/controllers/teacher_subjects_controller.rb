class TeacherSubjectsController < ApplicationController
  def index
    @teacher_subjects = TeacherSubject.all
  end
end
