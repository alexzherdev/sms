class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  validates_presence_of :middle_name, :allow_nil => true
  validates_inclusion_of :sex, :in => ["male", "female"]

  #define_index do
  #  indexes first_name, last_name, middle_name
  #end
  
  def middle_name
    return "" if read_attribute(:middle_name).blank?
    read_attribute(:middle_name)
  end

  #  Имя в формате "Полещук Максим Александрович" или "Полещук Максим"
  #
  def full_name(add_middle_name = true)
    return "#{last_name} #{first_name}" unless add_middle_name
    if middle_name.blank?
      _middle_name = ""
    else
      _middle_name = " " + middle_name
    end
    "#{last_name} #{first_name}" + _middle_name
  end
  
  #  Имя в формате "Полещук М. А."
  #
  def full_name_abbr
    if middle_name.blank?
      middle_name_short = ""
    else
      middle_name_short = " " + middle_name.first + "."
    end
    "#{last_name} #{first_name.first}.#{middle_name_short}"
  end
  
  def male?
    sex == "male"
  end

  def female?
    sex == "female"
  end
end