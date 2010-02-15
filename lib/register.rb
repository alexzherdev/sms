class Register
  attr_accessor :marks
  attr_accessor :schedule_items
  
  def create_dates(group, subject, start_date, end_date)
    self.schedule_items = ScheduleItem.find_all_by_student_group_id_and_subject_id(group, subject)
    day_count = {}
    self.schedule_items.each do |item|
      day_count[item.week_day] ||= []
      day_count[item.week_day] << item
    end
    
    day_count.keys.each do |key|
      day_count[key] = day_count[key].sort_by { |it| it.time_table_item }
    end
    
    dates = []
    
    cur_time = start_date
    while cur_time < end_date do
      if day_count.has_key?(cur_time.wday)
        dates.concat day_count[cur_time.wday].collect { |item| [ cur_time, item ] }
      end
      cur_time = 1.day.since cur_time
    end
    dates << [ nil, schedule_items.first ]
    dates
  end
  
  def initialize(marks)
    self.marks = marks
  end
  
  def create_mark_table(students, dates)
    mark_table = []
    students.each do |student|
      row = []
      dates.each do |date_and_item|
        new_mark = nil
        if date_and_item.first
          new_mark = Mark.new :mark => -2, :student_id => student.id, :date => date_and_item.first, :schedule_item_id => date_and_item.second.id
        else
          new_mark = TermMark.new :mark => -2, :student_id => student.id, :schedule_item_id => date_and_item.second.id
        end
        
        row << new_mark
      end
      mark_table << row
    end

    marks.each do |mark|
      index_of_student = students.index(mark.student)
      index_of_date = dates.index(mark.date ? [ mark.date, mark.schedule_item ] : [ nil, self.schedule_items.first ])

      mark_table[index_of_student][index_of_date] = mark
    end
    
    mark_table
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

    marks.each do |mark|
      index_of_student = students.index(mark.student)
      index_of_term_or_year = terms_and_year.index(mark.year_id ? [ nil, mark.year ] : [ mark.term, nil ])

      mark_table[index_of_student][index_of_term_or_year] = mark
    end
    
    mark_table
  end
end