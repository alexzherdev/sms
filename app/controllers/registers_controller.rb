class RegistersController < ApplicationController
  REGISTER_TIMESPAN = 2.months
  MARK_VALUES = (0..10).to_a
  
  def show
    session[:register_current_group_id] = params[:current_group]
    session[:register_current_subject_id] = params[:current_subject]
    @student_groups = current_user.student_groups_for_register
    return if @student_groups.blank?
    group = @student_groups[0]
    @read_only = (not current_user.can_edit_register?)
    @subjects = current_user.subjects_for_register(group)
    
    session[:register_current_group_id] ||= group.id
    if session[:register_current_subject_id].blank?
      session[:register_current_subject_id] = @subjects[0].id
    elsif not session[:register_current_group_id].blank?
      tmp_subj = Subject.find session[:register_current_subject_id]
      tmp_group = StudentGroup.find session[:register_current_group_id]
      tmp_subjects = current_user.subjects_for_register(tmp_group)
    
      @subjects = tmp_subjects
      session[:register_current_subject_id] = tmp_subjects[0].id unless tmp_subjects.include?(tmp_subj)
    end 
    
    @current_group_id = session[:register_current_group_id]
    @current_subject_id = session[:register_current_subject_id]
    
    if session[:register_start_date].blank?
      now = Time.now
      session[:register_end_date] = Time.utc(now.year, now.month, now.day)
      session[:register_start_date] = REGISTER_TIMESPAN.ago session[:register_end_date]
    end
    
    start_date = session[:register_start_date]
    end_date = session[:register_end_date]
    
    current_group = StudentGroup.find @current_group_id
    current_subject = Subject.find @current_subject_id
    
    marks = Mark.for_register(current_group, current_subject, start_date, end_date)
    @students = current_group.students
    @dates = Register.create_dates(current_group, current_subject, start_date, end_date)
    register = Register.new(marks)
    @mark_table = register.create_mark_table(@students, @dates)
  end
  
  def mark
    @i = params[:i].to_i
    @j = params[:j].to_i
    @mark = params[:mark].to_i
    mark = Mark.create :mark => @mark, :student_id => params[:student_id].to_i, :date => Time.parse(params[:date]), :schedule_item_id => params[:item_id].to_i, :modified_by_id => current_user.id

    render :action => "mark.rjs"
  end

end
