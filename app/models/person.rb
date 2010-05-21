class Person < ActiveRecord::Base
  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  validates_presence_of :patronymic, :allow_nil => true
  validates_inclusion_of :sex, :in => ["male", "female"]

  define_index do
    indexes first_name, last_name, patronymic
  end
  
  def patronymic
    return "" if read_attribute("patronymic").blank?
    read_attribute("patronymic")
  end

  #  Имя в формате "Полещук Максим Александрович" или "Полещук Максим"
  #
  def full_name(add_patronymic = true)
    return "#{last_name} #{first_name}" unless add_patronymic
    if patronymic.blank?
      _patronymic = ""
    else
      _patronymic = " " + patronymic
    end
    "#{last_name} #{first_name}" + _patronymic
  end
  
  #  Имя в формате "Полещук М. А."
  #
  def full_name_abbr
    if patronymic.blank?
      patronymic_short = ""
    else
      patronymic_short = " " + patronymic.first + "."
    end
    "#{last_name} #{first_name.first}.#{patronymic_short}"
  end
  
  def male?
    sex == "male"
  end

  def female?
    sex == "female"
  end
end