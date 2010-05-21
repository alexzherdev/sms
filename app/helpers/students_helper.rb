module StudentsHelper
  STUDENT_METHOD_FIELDS = [:id, :last_name, :first_name, :patronymic, :birth_date, :parent_email, :parent1_id, :parent2_id, :home_address, :student_group_id, :full_name]
  STUDENT_HELPER_FIELDS = [:student_group_name, :student_location]
  STUDENT_FIELDS = STUDENT_METHOD_FIELDS + STUDENT_HELPER_FIELDS
  def student_collection(students)
    students.collect do |student|
      STUDENT_METHOD_FIELDS.collect { |field| h(student.send field) }.concat STUDENT_HELPER_FIELDS.collect { |field| h(send("format_" + field.to_s, student)) }
    end
  end
  
  def format_student_group_name(student)
    return student.student_group_name unless student.student_group_name.blank?
    "Не зачислен ни в один класс"
  end
  
  def format_student_location(student) 
    return "" if student.student_group.blank?
    now = Time.now
    now = (now + now.gmt_offset).utc

    TimeTableItem.all.each do |tt|
      tstart = Time.utc now.year, now.month, now.day, tt.start_time.hour, tt.start_time.min, tt.start_time.sec
      tend = Time.utc now.year, now.month, now.day, tt.end_time.hour, tt.end_time.min, tt.end_time.sec

      if now >= tstart and now <= tend
        if tt.break?
          return "Сейчас #{format_sex(student)} на перемене."
        else
          schedule_item = ScheduleItem.find_by_student_group_id_and_week_day_and_time_table_item_id student.student_group.id, now.wday, tt.id
          if schedule_item.blank? 
            return "Сейчас у #{format_him_her(student)} нет занятий."
          else
            return "Сейчас #{format_sex(student)} в аудитории #{schedule_item.class_room.number}, идет #{schedule_item.subject.name}."
          end
        end
      end
    end
    return "Сейчас у #{format_him_her(student)} нет занятий."
    
  end
end
