module TimeTableItemsHelper
  def time_table_items_collection(time_table_items)
    index = 0
    time_table_items.collect do |time|
      index += 1 if time.lesson?
      to_time_table_record(time, index)
    end
  end
  
  def to_time_table_record(time, index)
    if time.lesson?
      [time.id, index, time.start_time.to_s(:lesson), time.end_time.to_s(:lesson)]
    elsif time.short_break? 
      [time.id, "", "Короткая перемена", ""]
    else
      [time.id, "", "Длинная перемена", ""]
    end
  end
end
