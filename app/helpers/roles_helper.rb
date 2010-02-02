module RolesHelper
  def acl_action_collection(actions)
    collect_values(actions, [:id, :title])
  end
end
