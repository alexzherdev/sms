module SubjectsHelper
  def full_subject_collection(subjects)
    collect_values(subjects, [ :id, :name, :year ])
  end
end
