module ClassRoomsHelper
  def class_room_collection(class_rooms)
    collect_values(class_rooms, [ :id, :number, :subject_ids ])
  end
  
  def subject_with_class_rooms_collection(subjects)
    subjects.collect do |subject|
      [ subject.id, "#{subject.name} #{subject.year}", subject.class_room_ids ]
    end
  end
end
