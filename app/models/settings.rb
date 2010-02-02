class Settings < ActiveRecord::Base
  serialize :value
  
  @cache = {}
  
  def self.[](name) 
    if not @cache.has_key?(name)
      @cache[name] = find_by_name(name).try(:value)
    end
    @cache[name]
  end
  
  def self.[]=(name, value)
    setting = find_or_initialize_by_name(name)
    setting.value = value
    setting.save
    @cache[name] = value
    setting
  end
end
