module Schedule
  class Generator
    attr_accessor :nice_schedule
    attr_accessor :rough_schedule
    attr_accessor :subjects_by_year
    attr_accessor :subjects_by_group
    attr_accessor :rooms_for_subject
    attr_accessor :group_no
    attr_accessor :group_teacher_subjects

    attr_accessor :lessons_to_distribute
    attr_accessor :group_count
    attr_accessor :day_count
    attr_accessor :lesson_count
    attr_accessor :class_room_map
    attr_accessor :subject_map
    attr_accessor :student_group_map

    attr_accessor :student_groups
    attr_accessor :lesson_times
    attr_accessor :subjects
    attr_accessor :teachers
    attr_accessor :all_rooms

    def generate_schedule
      self.nice_schedule = []
      self.rough_schedule = []
      create_schedule
      transform_to_schedule_items(self.nice_schedule)
    end

    def initialize(class_rooms, groups, subjs, less_times, teacher_subjects)
      init_class_rooms(class_rooms)
      init_student_groups(groups)
      init_subjects(subjs)
      init_rooms_for_subjects
      init_lesson_times(less_times)
      init_student_group_lessons
      init_teacher_subjects(teacher_subjects)
    end

    private 

    def fill_time_slices
      while self.lessons_to_distribute > 0 do
        time_slice = TimeSlice.new
        time_slice.full = true
        time_slice.lesson_count = 0
        lessons = []
        time_slice.lessons = lessons
    
        free_rooms = Array.new(self.all_rooms)
        free_teachers = Array.new(self.teachers)
        for i in 0...self.group_count do
          group = self.student_groups[i]
          group_lessons = subjects_by_group[group.id]
          if group_lessons.empty?
            time_slice.full = false
            next
          end
          available_lessons = get_available_lessons(free_rooms, free_teachers, group_lessons, group)
          if available_lessons.empty?
            time_slice.full = false
            next
          end
          lesson = get_random_lesson(available_lessons)
          if lesson
            lessons[i] = lesson
            remove_lesson(group_lessons, lesson.lesson)
            free_rooms.delete lesson.room
            teacher = self.group_teacher_subjects[group.id][lesson.lesson]
            free_teachers.delete teacher.id
            time_slice.lesson_count += 1
            self.lessons_to_distribute -= 1
          end
        end
        self.rough_schedule << time_slice
      end
  
      self.lessons_to_distribute = 0
      nice_slices = []
      for time_slice in self.rough_schedule do
        if time_slice.full
          nice_slices << time_slice
        else
          for i in 0...self.group_count do
            if time_slice.lessons[i]
              lesson = time_slice.lessons[i].clone
              group_id = group_no[i]
              self.subjects_by_group[group_id] << lesson
              self.lessons_to_distribute += 1
            end
          end
        end
      end
  
      for time_slice in nice_slices do 
        self.nice_schedule << time_slice
        self.rough_schedule.delete time_slice
      end
    end

    def create_schedule
      try_count = 0
      fill_time_slices
      prev_size = self.nice_schedule.length
      while try_count < 3 and self.rough_schedule.length > 0 do
        self.rough_schedule.clear
        fill_time_slices
        if prev_size == self.nice_schedule.length
          try_count += 1
        else
          try_count = 0
        end
        prev_size = self.nice_schedule.length
      end
      self.nice_schedule.concat self.rough_schedule
      self.nice_schedule
    end

    def remove_lesson(group_lessons, lesson)
      index = 0
      while index < group_lessons.length do
        if group_lessons[index].lesson == lesson
          break
        end
        index += 1
      end
      if index < group_lessons.length
        group_lessons.delete_at index
      end
    end

    def get_available_lessons(free_rooms, free_teachers, group_lessons, group)
      available = []
      for lesson in group_lessons do
        teacher = group_teacher_subjects[group.id][lesson.lesson]
        
        if !free_teachers.include?(teacher.id)
          next
        end
        possible_lesson = lesson.clone
        possible_lesson.rooms = []
        subject_rooms = rooms_for_subject[lesson.lesson]
        free_room_index = 0
        room_index = 0
        while free_room_index < free_rooms.length and room_index < subject_rooms.length do
          room = subject_rooms[room_index]
          free_room = free_rooms[free_room_index]
          if room > free_room
            free_room_index += 1
          elsif room < free_room
            room_index += 1
          else
            possible_lesson.rooms << room
            free_room_index += 1
            room_index += 1
          end
        end
        if possible_lesson.rooms.length > 0
          available << possible_lesson
        end
      end
      available
    end

    def get_random_lesson(available_lessons)
      lesson_index = (rand * available_lessons.length).to_i
      lesson = available_lessons[lesson_index]
      room_index = (rand * lesson.rooms.length).to_i
      room = lesson.rooms[room_index]
      random_lesson = Lesson.new
      random_lesson.lesson = lesson.lesson
      random_lesson.room = room
      random_lesson.rooms = lesson.rooms
      random_lesson
    end

    def init_class_rooms(class_rooms)
      self.class_room_map = []
      self.all_rooms = []
      for class_room in class_rooms do
        class_room_map[class_room.id] = class_room
        self.all_rooms << class_room.id
      end
      self.all_rooms = self.all_rooms.sort
    end

    def init_student_groups(groups)
      self.student_groups = groups
      self.student_group_map = []
      for student_group in groups do
        self.student_group_map[student_group.id] = student_group
      end
      self.group_count = groups.length
      self.group_no = []
      for i in 0...self.group_count do
        group_no[i] = groups[i].id
      end
    end

    def init_subjects(subjs)
      self.subjects = subjs
      self.subject_map = []
      for subj in subjs do
        self.subject_map[subj.id] = subj
      end
      self.subjects_by_year = []
      for subj in subjs do
        lessons = self.subjects_by_year[subj.year]
        if lessons.nil?
          lessons = []
          self.subjects_by_year[subj.year] = lessons
        end
        lesson = Lesson.new
        lesson.lesson = subj.id
        for i in 0...subj.hours_per_week do
          lessons << lesson.clone
        end
      end
    end

    def init_rooms_for_subjects
      self.rooms_for_subject = []
      for subject in self.subjects do
        rooms = []
        for room in subject.class_rooms do
          rooms << room.id
        end
        rooms = rooms.sort
        self.rooms_for_subject[subject.id] = rooms
      end
    end

    def init_student_group_lessons
      self.lessons_to_distribute = 0
      self.subjects_by_group = []
      for group in self.student_groups do
        subjects_for_year = self.subjects_by_year[group.year]
        subjects = []
        for lesson in subjects_for_year do
          subjects << lesson.clone
          self.lessons_to_distribute += 1
        end
        self.subjects_by_group[group.id] = subjects
      end
    end

    def init_lesson_times(less_times)
      self.lesson_times = Array.new(less_times).sort
      self.day_count = TimeTableItem::WEEK_DAYS.length
      self.lesson_count = self.lesson_times.length
    end
  
    def init_teacher_subjects(teacher_subjects)
      self.teachers = []
      self.group_teacher_subjects = []
      for ts in teacher_subjects do
        self.teachers << ts.teacher.id
        teacher_subject_map = group_teacher_subjects[ts.student_group_id]
        if teacher_subject_map.nil?
          teacher_subject_map = []
          self.group_teacher_subjects[ts.student_group_id] = teacher_subject_map
        end
        teacher_subject_map[ts.subject_id] = ts.teacher
      end
    end

    def transform_to_schedule_items(schedule)
      schedule_items = []
      day_no = 0
      lesson_no = 0
      for time_slice in schedule do
        for i in 0...time_slice.lessons.length do
          lesson = time_slice.lessons[i]
          if lesson.nil?
            next
          end
          item = ScheduleItem.new :week_day => TimeTableItem::WEEK_DAYS[day_no], :time_table_item => self.lesson_times[lesson_no], :class_room => self.class_room_map[lesson.room], :student_group => self.student_groups[i], :subject => self.subject_map[lesson.lesson]
          schedule_items << item
        end
        day_no += 1
        if day_no == self.day_count
          day_no = 0
          lesson_no += 1
          if lesson_no == self.lesson_count
            raise ArgumentError
          end
        end
      end
      schedule_items
    end  

  end

  class Lesson
    attr_accessor :lesson
    attr_accessor :room
    attr_accessor :rooms
  end

  class TimeSlice
    attr_accessor :lessons
    attr_accessor :lesson_count
    attr_accessor :full
  end
end