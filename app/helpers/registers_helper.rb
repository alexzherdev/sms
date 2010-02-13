module RegistersHelper
  def format_mark(mark)
    case mark
    when -1: "н"
    else mark
    end
  end
  
  def mark_value_collection
    Mark::MARK_VALUES.collect { |v| [ v, format_mark(v) ] }.to_json
  end
    
  def mark_collection(students, dates, mark_table)
    collection = []
    students.each_with_index do |student, i|
      collection[i] = []
      dates.each_with_index do |date, j|
        collection[i] << 
          {:id => mark_table[i][j].id, :i => i, :j => j, :mark => format_mark(mark_table[i][j].mark) }
      end
    end
    collection
  end
  
  def date_collection(dates)
    collection = []
    dates.each_with_index do |date, i|
      collection[i] = [ i, date.first.register_date_format, date.second.id, date.first.to_s ]
    end
    collection
  end
  
  def student_collection(students)
    index = -1
    students.collect do |student|
      [ student.id, index += 1, student.full_name ]
    end
  end
end
