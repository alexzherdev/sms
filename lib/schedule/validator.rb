require 'set'

module Schedule
  class Validator
    attr_accessor :items
    attr_accessor :errors
    
    def initialize(items)
      self.items = items
      self.errors = {}
    end
    
    def validate
      self.errors = {}
      check_rooms
      check_subjects_total_hours
      return self.errors.size == 0
    end
    
    def check_rooms
      occupied = {}
      first_occupied = {}
      for item in self.items do
        if occupied.has_key?(item.class_room)
          room_occupied_times = occupied[item.class_room]
          if room_occupied_times.include? [item.week_day, item.lesson_time]
            self.errors[item] ||= Set.new
            self.errors[item].add("Classroom is occupied")
            first_item = first_occupied[[item.class_room, item.week_day, item.lesson_time]]
            self.errors[first_item] ||= Set.new
            self.errors[first_item].add("Classroom is occupied")          
          else
            room_occupied_times.add [item.week_day, item.lesson_time]
            first_occupied[[item.class_room, item.week_day, item.lesson_time]] = item
          end
        else
          times = Set.new
          times.add [item.week_day, item.lesson_time]
          occupied[item.class_room] = times
          first_occupied[[item.class_room, item.week_day, item.lesson_time]] = item
        end
      end
    end
    
    def check_subjects_total_hours
      subject_hours = {}
      group_subject_items = {}
      not_enough = Set.new
      too_many = Set.new
      for item in self.items do
        subject = item.subject
        group = item.student_group
        pair = [group, subject]
        group_subject_items[pair] ||= []
        group_subject_items[pair] << item
        subject_hours[pair] ||= 0
        hours_collected = subject_hours[pair]
        if hours_collected + 1 > subject.hours_per_week
          too_many.add pair
        end
        subject_hours[pair] = hours_collected + 1
      end
      for pair in subject_hours.keys do
        if subject_hours[pair] < pair.second.hours_per_week
          not_enough.add [pair.first, pair.second]
        end
      end

      for pair in not_enough do
        for item in group_subject_items[pair] do
          self.errors[item] ||= Set.new
          self.errors[item].add("Not enough hours")
        end
      end
      for pair in too_many do
        for item in group_subject_items[pair] do
          self.errors[item] ||= Set.new
          self.errors[item].add("Too many hours")
        end
      end
    end
  end
end