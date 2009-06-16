module LessonTimesHelper
  def lesson_time_collection(lesson_times)
    index = 0
    lesson_times.collect do |time|
      index += 1
      [time.id, index, time.start_time.lesson_format, time.end_time.lesson_format]
    end
  end
end
