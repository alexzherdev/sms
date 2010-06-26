class Register
  attr_accessor :marks
  attr_accessor :schedule_items
  
  def initialize(marks)
    self.marks = marks
  end
  
  def create_dates(group, subject, start_date, end_date)
    self.schedule_items = ScheduleItem.find_all_by_student_group_id_and_subject_id group, subject
    items_by_day = get_items_by_day
    
    collect_dates_and_items(items_by_day, start_date, end_date)
  end

  def get_items_by_day
    items = {}
    self.schedule_items.each do |item|
      items[item.week_day] ||= []
      items[item.week_day] << item
    end
    items.keys.each do |key|
      items[key] = items[key].sort_by { |it| it.time_table_item }
    end
    items
  end
  
  def collect_dates_and_items(items_by_day, start_date, end_date)
    cur_time = start_date
    dates = []
    while cur_time < end_date do
      if items_by_day.has_key?(cur_time.wday)
        dates.concat items_by_day[cur_time.wday].collect { |item| [ cur_time, item ] }
      end
      cur_time = 1.day.since cur_time
    end
    dates << [ nil, schedule_items.first ]
  end
  
  def create_mark_table(students, dates)
    mark_table = []
    students.each do |student|
      row = []
      dates.each do |date_and_item|
        row << create_new_mark(student, date_and_item)
      end
      mark_table << row
    end

    put_marks_in_table
    
    mark_table
  end
  
  def create_new_mark(student, date_and_item)
    if date_and_item.first
      Mark.new :mark => -2, :student_id => student.id, :date => date_and_item.first, :schedule_item_id => date_and_item.second.id
    else
      TermMark.new :mark => -2, :student_id => student.id, :schedule_item_id => date_and_item.second.id
    end
  end
  
  def create_terms_and_year(year)
    year.terms.collect { |t| [ t, nil ] } + [[ nil, year ]]
  end
  
  def create_final_mark_table(students, terms_and_year)
    mark_table = []
    students.each do |student|
      row = []
      terms_and_year.each do |ty|
        new_mark = nil
        if ty.first.blank?
          new_mark = YearMark.new :mark => -2, :student_id => student.id, :year_id => ty.second.id
        else
          new_mark = TermMark.new :mark => -2, :student_id => student.id, :term_id => ty.first.id
        end
        row << new_mark
      end
      mark_table << row
    end

    put_terms_and_year_marks_in_table(mark_table, students, terms_and_year)
    
    mark_table
  end
  
  def put_marks_in_table(mark_table, students, dates)
    marks.each do |mark|
      index_of_student = students.index(mark.student)
      index_of_date = dates.index(mark.date ? [ mark.date, mark.schedule_item ] : [ nil, self.schedule_items.first ])

      mark_table[index_of_student][index_of_date] = mark
    end
  end

  def put_terms_and_year_marks_in_table(mark_table, students, terms_and_year)  
    marks.each do |mark|
      index_of_student = students.index(mark.student)
      index_of_term_or_year = terms_and_year.index(mark.year_id ? [ nil, mark.year ] : [ mark.term, nil ])

      mark_table[index_of_student][index_of_term_or_year] = mark
    end
  end
end