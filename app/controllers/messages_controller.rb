class MessagesController < ApplicationController
  def index
    @users = User.all
    @messages = current_user.mailbox.sent_messages
  end
  
  def show
    preload_message
    @message.read! if @message.copy?
  end
  
  def new
    @message = Mailbox::Message.new
    render :update do |page|
      page.replace_html "mailbox_main_panel", :partial => "new"
    end
  end
  
  def create
    @message = Mailbox::Message.create params[:message].merge(:mailbox_id => current_user.mailbox)
  end
  
  def reply
    preload_message
    @reply = @message.prepare_reply
    render :json => @reply.to_json(:methods => [:recipients_string, :recipient_ids])
  end
  
  def delete
    ids = params[:ids].split(",")
    if params[:copy] == "true"
      messages = Mailbox::MessageCopy.find :all, :conditions => [ "id in (?) and recipient_id = ?" , ids, current_user.id ]
    else
      messages = Mailbox::Message.find :all, 
          :conditions => [ "id in (?) and mailbox_id = ?" , ids, current_user.mailbox.id ]
    end
    [messages].flatten.each(&:delete!)
    render :nothing => true
  end
  
  protected
  
  def preload_message
    if params[:copy] == "true"
      @message = Mailbox::MessageCopy.find_by_id_and_recipient_id params[:id], current_user.id
    else
      @message = Mailbox::Message.find_by_id_and_mailbox_id params[:id], current_user.mailbox.id  
    end
  end
end
