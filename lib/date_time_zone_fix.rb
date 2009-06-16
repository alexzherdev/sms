ActiveRecord::ConnectionAdapters::Quoting.module_eval do
  #  We save +Date+ and +Time+ to the DB as UTC-based dates.
  #
  def quoted_date(value)
    new_value = value.is_a?(Date) ? value.send("new_offset", 0) : value.utc
    new_value.to_s(:db)
  end
end

ActiveRecord::ConnectionAdapters::Column.class_eval do
  def self.new_time(year, mon, mday, hour, min, sec, microsec)
    # Treat 0000-00-00 00:00:00 as nil.
    return nil if year.nil? || year == 0

    Time.send(:utc, year, mon, mday, hour, min, sec, microsec)
    # Over/underflow to DateTime
  rescue ArgumentError, TypeError
    DateTime.civil(year, mon, mday, hour, min, sec, 0) rescue nil
  end

  def self.string_to_time(string)
    return string unless string.is_a?(String)
    return nil if string.empty?

    fast_string_to_time(string) || DateTime.parse(string)
  end
end