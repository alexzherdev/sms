module TeachersHelper
  TEACHER_METHOD_FIELDS = [:id, :full_name]
  TEACHER_HELPER_FIELDS = [:group_teacher_info, :teacher_location]

  TEACHER_FIELDS = TEACHER_METHOD_FIELDS + TEACHER_HELPER_FIELDS
  
  def teacher_collection(teachers)
    teachers.collect do |teacher|
      TEACHER_METHOD_FIELDS.collect { |field| teacher.send field }.concat TEACHER_HELPER_FIELDS.collect { |field| send("format_" + field.to_s, teacher) }
    end
  end
  
  def format_group_teacher_info(teacher)
    if teacher.student_group
      "Классный руководитель #{teacher.student_group.full_name} класса"
    else 
      ""
    end
  end
  
  def format_teacher_location(teacher)
    return "Сейчас у #{format_him_her(teacher)} нет занятий." if teacher.teacher_subjects.blank?
    now = Time.now
    now = (now + now.gmt_offset).utc

    TimeTableItem.all.each do |tt|
      tstart = Time.utc now.year, now.month, now.day, tt.start_time.hour, tt.start_time.min, tt.start_time.sec
      tend = Time.utc now.year, now.month, now.day, tt.end_time.hour, tt.end_time.min, tt.end_time.sec

      if now >= tstart and now <= tend
        if tt.break?
          return "Сейчас перемена, возможно #{format_sex(teacher)} в учительской."
        else
          schedule_items = ScheduleItem.find_all_by_week_day_and_time_table_item_id now.wday, tt.id
          ts_subject_ids = teacher.teacher_subjects.collect(&:subject_id)
          
          for schedule_item in schedule_items do
            if ts_subject_ids.include?(schedule_item.subject_id)
              return "Сейчас #{format_sex(teacher)} в аудитории #{schedule_item.class_room.number}, ведет предмет \"#{schedule_item.subject.name}\"."
            end
          end
          return "Сейчас у #{format_him_her(teacher)} нет занятий."
        end
      end
    end
    return "Сейчас у #{format_him_her(teacher)} нет занятий."
    
  end
end