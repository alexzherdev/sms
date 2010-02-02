class TimeTableItem < ActiveRecord::Base
  WEEK_DAYS = (1..6).to_a
  
  LESSON = 0
  SHORT_BREAK = 1
  LONG_BREAK = 2
  
  validates_presence_of :start_time, :end_time
  validates_inclusion_of :item_type, :in => [ LESSON, SHORT_BREAK, LONG_BREAK ]

  default_scope :order => "start_time"
  
  named_scope :lessons, :conditions => { :item_type => LESSON }
  
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
  
  def self.lengths
    { LESSON => Settings["lesson_length"].to_i.minutes, SHORT_BREAK => Settings["short_break"].to_i.minutes, LONG_BREAK => Settings["long_break"].to_i.minutes }
  end
  
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
end
