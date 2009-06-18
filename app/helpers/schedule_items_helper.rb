module ScheduleItemsHelper
  def student_group_collection(student_groups)
    student_groups.collect do |group|
      [ group.id, group.full_name, group.year ]
    end
  end

end
