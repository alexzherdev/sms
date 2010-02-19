Time.class_eval do
  def lesson_format
    self.strftime("%H:%M")
  end
  
  def date_format
    self.strftime("%d-%m-%Y")
  end
  
  def register_date_format
    s = self.strftime("%a<br/>%d.%m")
    s.gsub!("Mon", "Пн")
    s.gsub!("Tue", "Вт")
    s.gsub!("Wed", "Ср")
    s.gsub!("Thu", "Чт")
    s.gsub!("Fri", "Пт")
    s.gsub!("Sat", "Сб")
    s
  end
  
  def date_format_for_js
    self.strftime("%m/%d/%Y")
  end
  
end