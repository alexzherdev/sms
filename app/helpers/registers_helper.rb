module RegistersHelper
  def mark_collection(students, dates, mark_table)
    collection = []
    students.each_with_index do |student, i|
      collection[i] = []
      dates.each_with_index do |date, j|
        collection[i] << 
          {:id => mark_table[i][j].id, :i => i, :j => j, :mark => mark_table[i][j].mark}
      end
    end
    collection
  end
  
  def mark_value_collection(marks)
    marks.collect(&:mark)
  end
  
  def student_collection(students)
    index = -1
    students.collect do |student|
      [ index += 1, student.name ]
    end
  end
end
