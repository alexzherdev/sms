module TeachersHelper
  TEACHER_METHOD_FIELDS = [:id, :full_name]
  TEACHER_HELPER_FIELDS = [:group_teacher_info]

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
end