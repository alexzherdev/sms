class RolesController < ApplicationController

  def index
    @roles = Role.all
  end
  
  def new
    @role = Role.new
    @unused_actions = AclAction.all
    render :partial => "form", :locals => { :url => roles_path, :method => "POST" }
  end
  
  def edit
    @role = Role.find params[:id]
    @unused_actions = AclAction.all - @role.acl_actions
    render :partial => "form", :locals => { :url => role_path(@role), :method => "PUT" }
  end
  
  def update
    @role = Role.find params[:id]
    @role.update_attributes params[:role]
    @unused_actions = AclAction.all - @role.acl_actions

    current_user.role.reload
    render :action => "update.rjs"
  end
end
