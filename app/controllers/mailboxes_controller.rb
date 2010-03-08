class MailboxesController < ApplicationController
  def folders
    render :partial => "folders.js.erb"
  end
  
  def folder
    folder = current_user.mailbox.folders.find params[:id]
    @messages = folder.message_copies
    render :action => "show_folder"
  end
  
  def sent
    @messages = current_user.mailbox.sent_messages
    render :action => "show_folder"
  end
  
  def trash
    @messages = current_user.mailbox.trash_messages
    render :action => "show_folder"
  end
end
