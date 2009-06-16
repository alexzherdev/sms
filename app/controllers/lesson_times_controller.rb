class LessonTimesController < ApplicationController
  def index
    @lesson_times = LessonTime.all
    @last_lesson = @lesson_times.last
  end

  def create
    lesson_times = LessonTime.all
    last = nil
    if lesson_times.length > 0
      last = lesson_times.last
      start = LessonTime::BREAK_LENGTH.since last.end_time
    else
      start = LessonTime::FIRST_LESSON_START
    end
    finish = LessonTime::LESSON_LENGTH.since start

    LessonTime.create :start_time => start, :end_time => finish 
    redirect_to lesson_times_path
  end

  def destroy
    lesson_time = LessonTime.find params[:id]
    lesson_time.destroy
    redirect_to lesson_times_path
  end

end
