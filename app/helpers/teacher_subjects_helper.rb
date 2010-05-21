module TeacherSubjectsHelper
  def teacher_subjects_collection(teacher_subjects)
    teacher_subjects.collect do |ts|
      [ ts.id, ts.teacher_id, ts.subject_id, ts.subject.name, ts.student_group_id, ts.student_group.full_name ]
    end
  end
end