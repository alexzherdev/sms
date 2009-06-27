class Role < ActiveRecord::Base
  has_and_belongs_to_many :acl_actions
end