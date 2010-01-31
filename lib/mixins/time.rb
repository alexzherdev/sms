Time.class_eval do
  def lesson_format
    self.strftime("%H:%M")
  end
  
  def date_format
    self.strftime("%Y-%m-%d")
  end
end