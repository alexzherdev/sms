# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  # AuthenticatedSystem must be included for RoleRequirement, and is provided by installing acts_as_authenticates and running 'script/generate authenticated account user'.
  #include AuthenticatedSystem
  # You can move this into a different controller, if you wish.  This module gives you the require_role helpers, and others.
  #include RoleRequirementSystem


  helper :all # include all helpers, all the time

  helper_method :current_user
  
  before_filter :login_required
  
  # See ActionController::RequestForgeryProtection for details
  # Uncomment the :secret if you're not using the cookie session store
  protect_from_forgery # :secret => '4ba57b4c46a8172ed51cef602d35123a'
  
  # See ActionController::Base for details 
  # Uncomment this to filter the contents of submitted sensitive data parameters
  # from your application log (in this case, all fields with names like "password"). 
  # filter_parameter_logging :password
  
  protected
  
  def action_protected?(controller_class, action_name)
    controller_settings = AclAction.find_by_name controller_class.controller_path
    return true unless controller_settings.blank?
    return AclAction.find_by_name compose_action_signature(controller_class, action_name)
  end
  
  def authorized? 
    return false unless current_user
    controller_class = self.class  
    action_name = params[:action]
    return true unless action_protected?(controller_class, action_name)
    
    signature = compose_action_signature(controller_class, action_name)

    return true if current_user.can_access?(controller_class.controller_path)
    return current_user.can_access?(signature)
  end
  
  #  Composes a key for the given controller and action to use a storage key. This key
  #  uniquely defines the actions we are to deal with.
  def compose_action_signature(controller_class, action_name)
    "#{controller_class.controller_path}/#{action_name}"
  end
  
  def login_required
    authorized? || access_denied
  end
  
  # Redirect as appropriate when an access request fails.
  #
  # The default action is to redirect to the login screen.
  #
  # Override this method in your controllers if you want to have special
  # behavior in case the user is not authorized
  # to access the requested action.  For example, a popup window might
  # simply close itself.
  def access_denied
    if current_user 
      render :template => "/errors/403" 
    else
      if request.xhr?
        render :update do |page|
          page.redirect_to login_url
        end
      else
        redirect_to login_url
      end
    end
  end
  
  def current_user_session
    return @current_user_session if defined?(@current_user_session)
    @current_user_session = UserSession.find
  end
  
  def current_user
    return @current_user if defined?(@current_user)
    @current_user = current_user_session && current_user_session.record
  end
  
  def local_request?
    false
  end
  
  def rescue_action_in_public(exception)
    status_code = response_code_for_rescue(exception)
    if status_code == :not_found
      render :template => "errors/404", :layout => false 
    else
      @exception = exception
      @show_backtrace = RAILS_ENV == "development"
      render :template => "errors/500"
    end    
  end
end
