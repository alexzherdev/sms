module UsersHelper
  def user_collection(users)
    collect_values(users, [:id, :last_name, :first_name, :login, :password])
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
