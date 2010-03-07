module RegistersHelper
  def format_mark(mark)
    case mark
    when -1: "н"
    else mark
    end
  end
  
  def term_name(term)
    "#{term.ordinal} четверть"
  end
  
  def short_term_name(term)
    "#{term.ordinal}<br/>четв."
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
          {:id => mark_table[i][j].id, :i => i, :j => j, :mark => format_mark(mark_table[i][j].mark), :type => mark_table[i][j].type, :term_id => mark_table[i][j].term_id, :year_id => mark_table[i][j].year_id }
      end
    end
    collection
  end
  
  def date_collection(dates)
    collection = []
    dates.each_with_index do |date, i|
      collection[i] = [ i, (date.try(:first) ? date.first.to_s(:register) : nil), date.try(:second).try(:id), date.try(:first).try(:to_s) ]
    end
    collection
  end
  
  def student_collection(students)
    index = -1
    students.collect do |student|
      [ student.id, index += 1, student.full_name ]
    end
  end
  
  def final_column_collection(terms_and_year, group, subject)
    collection = []
    terms_and_year.each_with_index do |ty, i|
      if ty.first.blank?
        collection[i] = [ i, "Год.<br/><br/>", "", "" ]
      else
        collection[i] = [ i, short_term_name(ty.first), "", "" ]
      end
    end
    collection
  end
  
  def register_term_collection(terms)
    terms.collect do |t|
      [ t.id, term_name(t) ]
    end + [[ "", "Итоговые" ]]
  end
end
