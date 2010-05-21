class TimeTableItem < ActiveRecord::Base
  WEEK_DAYS = (1..6).to_a
  
  LESSON = 0
  SHORT_BREAK = 1
  LONG_BREAK = 2
  
  validates_presence_of :start_time, :end_time
  validates_inclusion_of :item_type, :in => [ LESSON, SHORT_BREAK, LONG_BREAK ]

  default_scope :order => "start_time"
  
  named_scope :lessons, :conditions => { :item_type => LESSON }
  
  #  Возвращает хэш с длительностями уроков и перемен.
  #
  def self.lengths
    { LESSON => Settings["lesson_length"].to_i.minutes, SHORT_BREAK => Settings["short_break"].to_i.minutes, LONG_BREAK => Settings["long_break"].to_i.minutes }
  end
  
  #  Добавляет айтем нужного типа в конец расписания звонков.
  #
  #  * <tt>item_type</tt>:: Тип айтема.
  #
  def self.add(item_type)
    time_table_items = self.all
    last = nil
    if time_table_items.length > 0
      last = time_table_items.last
      start = last.end_time
    else
      start = Settings["lessons_start"]
    end
    finish = lengths[item_type].since start
    self.create :start_time => start, :end_time => finish, :item_type => item_type
  end
  
  #  Пересчитывает времена начала и конца айтемов в расписании.
  #
  def self.recalculate_times
    items = self.all
    return if items.size == 0
    current_time = Settings["lessons_start"]

    items.each do |item|
      item.start_time = current_time  
      item.end_time = lengths[item.item_type].since item.start_time
      current_time = item.end_time
      item.save
    end
  end
  
  def <=>(time_table_item)
    return self.start_time <=> time_table_item.start_time
  end
  
  def lesson?
    self.item_type == LESSON
  end
  
  def short_break?
    self.item_type == SHORT_BREAK
  end
  
  def long_break?
    self.item_type == LONG_BREAK
  end
  
  def break?
    short_break? or long_break?
  end
  
  #  Удаляет этот айтем из расписания и сдвигает по времени все последующие.
  #
  def destroy_and_shift
    later_items = self.class.find(:all, :conditions => [ "start_time > ?", self.start_time ])
    delta = self.end_time - self.start_time
    self.destroy
    later_items.each do |item|
      item.start_time -= delta
      item.end_time -= delta
      item.save
    end
  end
end
