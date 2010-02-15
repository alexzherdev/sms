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
end
