module ClassRoomsHelper
  def class_room_collection(class_rooms)
    collect_values(class_rooms, [ :id, :number, :subject_ids ])
  end
  
  def subject_with_class_rooms_collection(subjects)
    collect_values(subjects, [ :id, :name, :class_room_ids ])
  end
end
