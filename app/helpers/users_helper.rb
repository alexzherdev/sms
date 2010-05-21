module UsersHelper
  USER_FIELDS = [:id, :last_name, :first_name, :patronymic, :login, :password, :full_name, :full_name_abbr]
  
  def user_collection(users)
    collect_values(users, USER_FIELDS)
  end
  
  def role_collection(roles)
    collect_values(roles, [:id, :name])
  end

  def format_sex(person) 
    person.male? ? "он" : "она"
  end
  
  def format_him_her(person)
    person.male? ? "него" : "нее"
  end
end
