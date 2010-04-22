module StudentsHelper
  STUDENT_FIELDS = [:id, :last_name, :first_name, :birth_date, :parent_email, :parent1_id, :parent2_id, :home_address, :student_group_id]
  def full_student_collection(students)
    collect_values(students, STUDENT_FIELDS)
  end
end
