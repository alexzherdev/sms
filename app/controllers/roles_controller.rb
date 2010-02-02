class RolesController < ApplicationController
  def index
    @roles = Role.all
  end
  
  def new
    @role = Role.new
    @unused_actions = AclAction.all
    render :partial => "form", :locals => { :url => roles_path, :method => "POST" }
  end
  
  def create
    @role = Role.new params[:role]
    @role.save
    @unused_actions = AclAction.all - @role.acl_actions
    render :action => "create.rjs", :status => @role.valid? ? 200 : 403
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
    if @role.valid?
      render :text => ""
    else
      render :text => "", :status => 403
    end
  end
end
