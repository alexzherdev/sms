module UsersHelper
  USER_FIELDS = [:id, :last_name, :first_name, :patronymic, :login, :password, :full_name, :full_name_abbr]
  def user_collection(users)
    collect_values(users, USER_FIELDS)
  end
  
  def role_collection(roles)
    collect_values(roles, [:id, :name])
  end
  
  def collect_values(collection, methods)
    collection.collect do |obj|
      methods.collect do |meth|
        obj.send(meth)
      end
    end
  end
end
