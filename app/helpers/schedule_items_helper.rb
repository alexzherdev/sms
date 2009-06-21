module ScheduleItemsHelper
  def student_group_collection(student_groups)
    student_groups.collect do |group|
      [ group.id, group.full_name, group.year ]
    end
  end

  def day_time_collection(day_times)
    collection = []
    day_times.each_with_index do |dt, i|
      collection << [i, dt.first, dt.second.start_time.lesson_format]
    end
    collection
  end
  
  def schedule_item_collection(day_times, groups, item_table)
    collection = []
    day_times.each_with_index do |dt, i|
      collection[i] = []
      groups.each_with_index do |group, j|
        collection[i] << 
          [item_table[i][j].id, i, j, item_table[i][j].subject.id, item_table[i][j].class_room.id, group.id]
      end
    end
    collection
  end
  
  def room_collection(rooms)
    rooms.collect do |room|
      [room.id, room.number, "false"]
    end
  end
  
  def subject_collection(subjects)
    subjects.collect do |subject|
      [subject.id, subject.name]      
    end
  end
end
