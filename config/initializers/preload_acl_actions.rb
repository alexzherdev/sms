require 'acl_action'
begin
  ACL_ACTIONS_MAP = AclAction.preload
rescue
end