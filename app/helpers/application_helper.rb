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
  
  def link_to_mailbox
    if current_user.mailbox.inbox.unread_count == 0
      link_to "Мои сообщения", mailbox_messages_path
    else
      content_tag("b", link_to("Мои сообщения (#{current_user.mailbox.inbox.unread_count})", mailbox_messages_path))
    end
  end
  
  def acl_block(path, &block)
    path = path[1..-1] if path.index("/") == 0
    controller_path = path.split("/")[0]
    action_name = path.split("/")[1] || "index"

    if authorized?(controller_path, action_name)
      html = capture(&block)
      concat html
    end
  end
end
