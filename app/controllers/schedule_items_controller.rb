class ScheduleItemsController < ApplicationController
  def index
    @schedule_items = ScheduleItem.all
    @student_groups = StudentGroup.all
    @year_subjects = {}
    empty_subject = Subject.new { |subject| subject.id = 0; subject.name = "Empty" }
    Subject::SCHOOL_YEARS.each do |year|
      subjects = Subject.by_year(year)
      subjects.unshift(empty_subject)
      @year_subjects[year] = subjects
    end
    
    @class_rooms = ClassRoom.all
    empty_room = ClassRoom.new { |room| room.id = 0; room.number = "Empty" }
    @class_rooms.unshift(empty_room)
    @day_times = create_day_times
    @item_table = create_item_table(@schedule_items, @day_times, @student_groups)
  end
  
  def save
    if (params[:id].to_i == 0)
      @day_times = create_day_times
      @student_groups = StudentGroup.all
      day_time = @day_times[params[:i].to_i]
      group = @student_groups[params[:j].to_i]
      
      item = ScheduleItem.new
      item.week_day = day_time.first
      item.student_group = group
      item.lesson_time = day_time.second
    else
      item = ScheduleItem.find params[:id]
    end

    item.subject_id = params[:subject_id].to_i
    item.class_room_id = params[:room_id].to_i
    item.save
    render :template => "schedule_items/save_item.rjs"
  end
  
  def generate
    ScheduleItem.delete_all
    sg = ScheduleGenerator.new ClassRoom.all, StudentGroup.all, Subject.all, LessonTime.all, TeacherSubject.all
    items = sg.generate_schedule
    for item in items do
      item.save
    end
    redirect_to schedule_items_path
  end
  
  protected
  
  def create_item_table(schedule_items, day_times, groups)
    item_table = []
    empty_room = ClassRoom.new { |room| room.id = 0 }
    empty_subject = Subject.new { |subject| subject.id = 0 }
    day_times.each_with_index do |day_time, i|
      item_table << []
      groups.each do |group|
        new_item = ScheduleItem.new(:week_day => day_time.first, :lesson_time => day_time.second, :student_group => group, :subject => empty_subject, :class_room => empty_room) { |item| item.id = 0 }
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
    day_times = []
    week_days.each do |week_day|
      lesson_times.each do |lesson_time|
        day_times << [week_day, lesson_time]
      end
    end
    day_times
  end
end
