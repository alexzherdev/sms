class UserSession < Authlogic::Session::Base
  def to_key
    persisted? ? [id.to_s] : nil
  end
  
  def persisted?
    !(new_record? || destroyed?)
  end
end