class StudentGroupsController < ApplicationController
  def index
    @student_groups = StudentGroup.all
    @teachers = Teacher.all
  end
  
  def new
    @student_group = StudentGroup.new
    render :partial => "form", :locals => { :url => student_groups_path, :method => "POST" }
  end
  
  def create
    @student_group = StudentGroup.create params[:student_group]
    render :action => "create.rjs", :status => @student_group.valid? ? 200 : 403
  end
  
  def destroy
    if not ScheduleItem.find_by_student_group_id params[:id]
      @student_group = StudentGroup.find(params[:id])
      @student_group.destroy
    end
    render :action => "destroy.rjs"
  end
  
  def edit
    @student_group = StudentGroup.find params[:id]
    render :partial => "form", :locals => { :url => student_group_path(@student_group), :method => "PUT" }
  end
  
  def update
    @student_group = StudentGroup.find(params[:id])
    @student_group.update_attributes params[:student_group]
    render :action => "update.rjs", :status => @student_group.valid? ? 200 : 403
  end

  def notify
    @student_group = StudentGroup.find(params[:id])
    @student_group.students.each { |student|
      weekly_diary = Mark.for_weekly_notification(student, Time.now)
      Mailer.deliver_student_weekly_results(student,  weekly_diary)
    }
    render :action => "notify.rjs"
  end
end
