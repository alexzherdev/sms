class StudentGroupsController < ApplicationController
  def index
    @student_groups = StudentGroup.all
  end
  
  def new
    @student_group = StudentGroup.new
  end
  
  def create
    @student_group = StudentGroup.new(params[:student_group])
    if @student_group.save
      flash[:notice] = "Successfully created student group."
      redirect_to student_groups_url
    else
      render :action => 'new'
    end
  end
end
