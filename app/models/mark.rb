class Mark < ActiveRecord::Base
  MARK_VALUES = (-1..10).to_a
  
  belongs_to :student
  belongs_to :schedule_item
  belongs_to :term
  belongs_to :modified_by, :class_name => "Teacher"
  
  validates_presence_of :student, :modified_by
  
  #  Находит все оценки для журнала за четверть (включая четвертные).
  #   
  #  * <tt>group</tt>:: Просматриваемый класс.
  #  * <tt>subject</tt>:: Просматриваемый предмет.
  #  * <tt>term</tt>:: Четверть. 
  #
  def self.for_register(group, subject, term)
    self.find(:all, :include => :schedule_item, :conditions => [ "schedule_items.student_group_id = ? and schedule_items.subject_id = ? and term_id = ?", group.id, subject.id, term.id ])
  end
  
  #  Находит все оценки для страницы итоговых оценок (четвертных и годовых).
  #   
  #  * <tt>group</tt>:: Просматриваемый класс.
  #  * <tt>subject</tt>:: Просматриваемый предмет.
  #  * <tt>year</tt>:: Год. 
  #
  def self.for_register_finals(group, subject, year)
    self.find(:all, :include => :schedule_item, :conditions => [ "schedule_items.student_group_id = ? and schedule_items.subject_id = ? and ((term_id in (?) and date is null) or (year_id = ?))", group.id, subject.id, year.term_ids, year.id ])
  end

  #  Находит все оценки для страницы итоговых оценок (четвертных и годовых).
  #
  #  * <tt>group</tt>:: Просматриваемый класс.
  #  * <tt>subject</tt>:: Просматриваемый предмет.
  #  * <tt>year</tt>:: Год.
  #
  def self.for_weekly_notification(student, date)
    self.find(:all, :include => :schedule_item, :conditions => [ "schedule_items.student_group_id = ? and schedule_items.subject_id = ? and ((term_id in (?) and date is null) or (year_id = ?))", group.id, subject.id, year.term_ids, year.id ])
  end

  named_scope :for_weekly_notification, lambda { |student, date| {:include => :schedule_item,  :conditions  => { :student => student, :date  => date.beginning_of_week..date.end_of_week } } }
end