Time.class_eval do
  def lesson_format
    self.strftime("%H:%M")
  end
end