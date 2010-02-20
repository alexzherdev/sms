class RegistersController < ApplicationController
  before_filter :load_models, :except => :mark

  def show    
    @start_date = @term.start_date
    @end_date = @term.end_date
    marks = Mark.for_register(@current_group, @current_subject, @term)
    register = Register.new(marks)
    @dates = register.create_dates(@current_group, @current_subject, @start_date, @end_date)

    @mark_table = register.create_mark_table(@students, @dates)

  end
  
  def mark
    @i = params[:i].to_i
    @j = params[:j].to_i
    @mark = params[:mark].to_i
    if params[:type] == "TermMark"
      mark = TermMark.create :mark => @mark, :student_id => params[:student_id].to_i, :schedule_item_id => params[:item_id].to_i, :modified_by_id => current_user.id, :term_id => (params[:term_id] || session[:register_current_term_id])
    elsif params[:type] == "YearMark"
      mark = YearMark.create :mark => @mark, :student_id => params[:student_id].to_i, :schedule_item_id => params[:item_id].to_i, :modified_by_id => current_user.id, :year_id => session[:register_current_year_id]
    else
      mark = Mark.create :mark => @mark, :student_id => params[:student_id].to_i, :date => Time.parse(params[:date]), :schedule_item_id => params[:item_id].to_i, :modified_by_id => current_user.id, :term_id => session[:register_current_term_id]
      
    end
    
    render :action => "mark.rjs"
  end

  def final
    year = Year.find params[:current_year]
    marks = Mark.for_register_finals @current_group, @current_subject, year
    register = Register.new(marks)
    @terms_and_year = register.create_terms_and_year(year)
    @mark_table = register.create_final_mark_table(@students, @terms_and_year)
    @item = ScheduleItem.find_by_student_group_id_and_subject_id(@current_group, @current_subject)
  end
  
  protected
  
  def load_models
    session[:register_current_group_id] = params[:current_group]
    session[:register_current_subject_id] = params[:current_subject]
    session[:register_current_year_id] = params[:current_year]
    session[:register_current_term_id] = params[:current_term]
    
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
    
    year = Year.with_terms[0]
    session[:register_current_year_id] ||= year.id
    Rails.logger.error "*" * 100
    Rails.logger.error session[:register_current_year_id]
    if session[:register_current_term_id].nil?
      session[:register_current_term_id] = year.terms[0].id
      Rails.logger.error "-" * 100
      Rails.logger.error session[:register_current_term_id]
    elsif not session[:register_current_year_id].blank?
      tmp_year = Year.find session[:register_current_year_id] 

      if (session[:register_current_term_id] != "" and not tmp_year.term_ids.include?(session[:register_current_term_id].to_i))
        Rails.logger.error "%" * 100
        Rails.logger.error session[:register_current_term_id]
        session[:register_current_term_id] = tmp_year.terms[0].id 
        Rails.logger.error session[:register_current_term_id]
      end
    end
    
    @term = Term.find session[:register_current_term_id] rescue nil
    
    @current_year_id = session[:register_current_year_id]
    @current_term_id = session[:register_current_term_id]
    @years = Year.with_terms
    @terms = Term.find_all_by_year_id(@current_year_id)
    
    @current_group = StudentGroup.find @current_group_id
    @current_subject = Subject.find @current_subject_id
    @students = @current_group.students
  end
end
