# coding: utf-8

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
  
  def collect_values(collection, methods)
    collection.collect do |obj|
      methods.collect do |meth|
        obj.send(meth)
      end
    end
  end
  
  def link_or_bold(text, url)
    if current_page?(url) or (url.include?("/register") and params[:controller] == "registers") or (url.include?("/roles") and params[:controller] == "roles")
      content_tag "b", text
    else 
      link_to text, url
    end
  end
  
  def menu_items
    [
      ["Пользователи", users_path], 
      ["Роли", roles_path],
      ["Учебные годы и четверти", years_path],
      ["Расписание звонков", time_table_items_path],
      ["Аудитории", class_rooms_path],
      ["Ученики", students_path],
      ["Классы", student_groups_path],
      ["Предметы", subjects_path],
      ["Нагрузка учителей", teacher_subjects_path],
      ["Расписание занятий", schedule_path],
      ["Журналы", register_path]
    ]
  end
  
  def link_to_mailbox
    in_mailbox = ["mailboxes", "messages"].include? params[:controller]
    if current_user.mailbox.inbox.unread_count == 0
      if in_mailbox
        content_tag "b", "Мои сообщения"
      else
        link_to "Мои сообщения", mailbox_messages_path
      end
    else
      text = "Мои сообщения (#{current_user.mailbox.inbox.unread_count})"
      content = in_mailbox ? text : link_to(text, mailbox_messages_path)
      content_tag "b", content
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
