class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  
  def full_name
    "#{last_name} #{first_name}"
  end
  
end