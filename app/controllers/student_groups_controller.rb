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
      #marks = Mark.for_weekly_notification(student, Time.now)
      date = Time.now
      weekly_diary = ScheduleItem.find(
        :all,
        :select => "schedule_items.*, marks.date, subjects.name, marks.mark",
        :joins => "LEFT JOIN marks ON marks.schedule_item_id = schedule_items.id AND marks.student_id =#{student.id}",
        :include => :subject,
        :conditions => ["schedule_items.student_group_id = ? and marks.date BETWEEN ? and ?",
          @student_group.id, date.beginning_of_week, date.end_of_week],
        :order => :week_day
      ).collect(&:mark)
      Mailer.deliver_student_weekly_results(student,  weekly_diary)  
    }
    render :action => "notify.rjs"
  end
end
