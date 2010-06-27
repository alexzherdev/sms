class Mark < ActiveRecord::Base
  MARK_VALUES = (-1..10).to_a
  
  belongs_to :student
  belongs_to :schedule_item
  belongs_to :term
  belongs_to :modified_by, :class_name => "Teacher"
  
  validates_presence_of :student, :modified_by
  
  scope :for_weekly_notification, lambda { |student, date| {:include => :schedule_item,  :conditions  => { :student => student, :date  => date.beginning_of_week..date.end_of_week } } }
  
  class << self
    #  Находит все оценки для журнала за четверть (включая четвертные).
    #   
    #  * <tt>group</tt>:: Просматриваемый класс.
    #  * <tt>subject</tt>:: Просматриваемый предмет.
    #  * <tt>term</tt>:: Четверть. 
    #
    def for_register(group, subject, term)
      scope includes(:schedule_item).where([ "schedule_items.student_group_id = ? and schedule_items.subject_id = ? and term_id = ?", group.id, subject.id, term.id ])
    end
  
    #  Находит все оценки для страницы итоговых оценок (четвертных и годовых).
    #   
    #  * <tt>group</tt>:: Просматриваемый класс.
    #  * <tt>subject</tt>:: Просматриваемый предмет.
    #  * <tt>year</tt>:: Год. 
    #
    def for_register_finals(group, subject, year)
      scope includes(:schedule_item).where([ "schedule_items.student_group_id = ? and schedule_items.subject_id = ? and ((term_id in (?) and date is null) or (year_id = ?))", group.id, subject.id, year.term_ids, year.id ])
    end

    #  Находит все оценки студента за неделю для отчёта(дневника).
    #
    #  * <tt>student</tt>:: Студент.
    #  * <tt>date</tt>:: Любая дата в течение нужной недели.
    #
    def for_weekly_notification(student, date)
      scope joins({ :schedule_item => :subject}).where({
            :student_id => student.id,
            :date => date.beginning_of_week..date.end_of_week,
            'schedule_items.student_group_id' => student.student_group_id
          }).order(:week_day)
    end
  end
end