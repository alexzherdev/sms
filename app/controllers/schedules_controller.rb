class SchedulesController < ApplicationController
  def show
    @schedule_items = ScheduleItem.all
    @student_groups = StudentGroup.all
    @year_subjects = {}
    empty_subject = Subject.new { |subject| subject.id = 0; subject.name = "Пусто" }
    Subject::SCHOOL_YEARS.each do |year|
      subjects = Subject.by_year(year)
      subjects.unshift(empty_subject)
      @year_subjects[year] = subjects
    end

    validator = Schedule::Validator.new(@schedule_items)
    validator.validate
    @errors = validator.errors

    @class_rooms = ClassRoom.all
    empty_room = ClassRoom.new { |room| room.id = 0; room.number = "Пусто" }
    @class_rooms.unshift(empty_room)

    @day_times = create_day_times

    return if @day_times.empty? || @student_groups.empty?

    @item_table = create_item_table(@schedule_items, @day_times, @student_groups)
  end
  
  def save
    new_item = false
    if (params[:id].to_i == 0)
      @day_times = create_day_times
      @student_groups = StudentGroup.all
      day_time = @day_times[params[:i].to_i]
      group = @student_groups[params[:j].to_i]
      
      item = ScheduleItem.new
      item.week_day = day_time.first
      item.student_group = group
      item.time_table_item = day_time.second
      new_item = true
    else
      item = ScheduleItem.find params[:id]
    end
    
    if params[:subject_id] == "0" and params[:room_id] == "0"
      item.destroy
      @deleted = true
    else
      item.subject_id = params[:subject_id].to_i
      item.class_room_id = params[:room_id].to_i
      item.save
      @new_item_id = item.id if new_item
    end
    @schedule_items = ScheduleItem.all
    validator = Schedule::Validator.new(@schedule_items)
    validator.validate
    @errors = validator.errors
    render :template => "schedules/save.rjs"
  end
  
  def generate
    ScheduleItem.delete_all
    sg = Schedule::Generator.new ClassRoom.all, StudentGroup.all, Subject.all, TimeTableItem.lessons, TeacherSubject.all
    items = sg.generate_schedule

    ScheduleItem.transaction do
      for item in items do
        item.save
      end
    end
    redirect_to schedule_path
  end
  
  protected
  
  def create_item_table(schedule_items, day_times, groups)
    item_table = []
    empty_room = ClassRoom.new { |room| room.id = 0 }
    empty_subject = Subject.new { |subject| subject.id = 0 }
    day_times.each_with_index do |day_time, i|
      item_table << []
      groups.each do |group|
        new_item = ScheduleItem.new(:week_day => day_time.first, :time_table_item => day_time.second, :student_group => group, :subject => empty_subject, :class_room => empty_room) { |item| item.id = 0 }
        item_table[i] << new_item
      end  
    end
    schedule_items.each do |item|
      day_time_index = day_times.index([item.week_day, item.time_table_item])
      group_index = groups.index(item.student_group)
      item_table[day_time_index][group_index] = item
    end
    item_table
  end
  
  def create_day_times
    lesson_times = TimeTableItem.lessons
    week_days = TimeTableItem::WEEK_DAYS
    day_times = []
    week_days.each do |week_day|
      lesson_times.each do |lesson_time|
        day_times << [week_day, lesson_time]
      end
    end
    day_times
  end
end
