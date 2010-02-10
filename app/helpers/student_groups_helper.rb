module StudentGroupsHelper
  def small_student_collection(students)
    collect_values(students, [ :id, :full_name ])
  end
end
