class MessagesController < ApplicationController
  before_filter :preload_message, :only => [:show, :reply, :reply_all, :forward]
  
  def index
    @users = User.all
    @messages = current_user.mailbox.sent_messages
  end
  
  def show
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
    @reply = @message.prepare_reply
    render :json => @reply.to_json(:methods => [:recipients_string, :recipient_ids])
  end
  
  def reply_all
    @reply = @message.prepare_reply_all
    render :json => @reply.to_json(:methods => [:recipients_string, :recipient_ids])
  end
  
  def forward
    @forward = @message.prepare_forward
    render :json => @forward.to_json(:methods => [:recipients_string, :recipient_ids])
  end
  
  def delete
    ids = params[:ids].split(",")
    if params[:copy] == "true"
      messages = Mailbox::MessageCopy.find :all, :conditions => [ "id in (?) and recipient_id = ?" , ids, current_user.id ]
    else
      messages = Mailbox::Message.find :all, 
          :conditions => [ "id in (?) and mailbox_id = ?", ids, current_user.mailbox.id ]
    end
    [messages].flatten.each(&:delete!)
    render :nothing => true
  end
  
  def restore
    ids = params[:ids].split(",")
    copy = params[:copy].split(",")
    ids.each_with_index do |id, i|
      if copy[i] == "true"
        message = Mailbox::MessageCopy.find_by_id_and_recipient_id id, current_user.id
      else
        message = Mailbox::Message.find_by_id_and_mailbox_id id, current_user.mailbox.id  
      end
      message.restore!
    end
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
