# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper
  
  #  Returns a new integer that is guaranteed not to repeat in the current render
  #  phase.
  def new_gui_id
    @gui_id ||= Time.now.hash.abs
    @gui_id += 1
  end
  
  def school_year_store(name = "school_year_store")
    render :partial => "partials/school_year_store.js.erb", :locals => { :name => name }
  end
  
  def acl_block(path, &block)
    if current_user.can_access? path
      html = capture(&block)
      concat html, block.binding
    end
  end
end
