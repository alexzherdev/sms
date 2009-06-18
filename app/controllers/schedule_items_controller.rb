class ScheduleItemsController < ApplicationController
  def index
    @schedule_items = ScheduleItem.all
    @student_groups = StudentGroup.all
    @subjects = Subject.all
    @class_rooms = ClassRoom.all
    @day_times = create_day_times
    @item_table = create_item_table(@schedule_items, @day_times, @student_groups)
  end
  
  protected
  def create_item_table(schedule_items, day_times, groups)
    item_table = []
    day_times.each_with_index do |day_time, i|
      item_table << []
      groups.each do |group|
        new_item = ScheduleItem.new :week_day => day_time.first, :lesson_time => day_time.second, :student_group => group
        item_table[i] << new_item
      end  
    end
    schedule_items.each do |item|
      day_time_index = day_times.index([item.week_day, item.lesson_time])
      group_index = groups.index(item.student_group)
      item_table[day_time_index][group_index] = item
    end
    return item_table
  end
  
  def create_day_times
    lesson_times = LessonTime.all
    week_days = LessonTime::WEEK_DAYS
    week_days.collect do |week_day|
      lesson_times.collect do |lesson_time|
        [week_day, lesson_time]
      end
    end
  end
end
