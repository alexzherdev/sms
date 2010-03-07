class AclAction < ActiveRecord::Base
  has_and_belongs_to_many :roles
  
  def self.preload
    self.all.inject({}) do |cache, action|
      cache[action.name] = action
      cache
    end
  end
  
  def self.by_name(name)
    if ACL_ACTIONS_MAP.has_key?(name)
      ACL_ACTIONS_MAP[name]
    else
      ACL_ACTIONS_MAP[name] = find_by_name name
    end
  end
end
