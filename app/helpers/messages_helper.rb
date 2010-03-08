module MessagesHelper
  MESSAGE_FIELDS = ["id", "subject", "body", "short_body", "status", "recipients_string", "created_at", "is_copy", "folder_id"]
  
  def message_collection(messages)
    messages.collect do |msg|
      [msg.id, msg.subject, msg.body, truncate(strip_tags(msg.body.gsub("<br>", " ")), :length => 50 - msg.subject.length), msg.status, truncate(msg.recipients_string, :length => 50), msg.created_at.to_s(:message), msg.copy?, msg.folder_id]
    end
  end
  
  def mailbox_folders
    common = { :leaf => true, :uiProvider => "FolderTreeNodeUI".j }
    strip_hash_keys_for_json([
      { :text => folder_text(current_user.mailbox.inbox), :url => mailbox_folder_path(:id => current_user.mailbox.inbox.id), :id => current_user.mailbox.inbox.id, :unread_count => current_user.mailbox.inbox.unread_count }.merge(common),
      { :text => current_user.mailbox.sent[:name], :url => mailbox_sent_path, :id => current_user.mailbox.sent[:id] }.merge(common),
      { :text => current_user.mailbox.trash[:name], :url => mailbox_trash_path, :id => current_user.mailbox.trash[:id] }.merge(common)
    ]).to_json
  end
  
  def folder_text(folder)
    text = folder.name
    if folder.unread_count > 0
      text = content_tag("b", "#{text} (#{folder.unread_count})")
    end
    text
  end
end
