class MessagesController < ApplicationController
  def index
    @users = User.all
    @messages = current_user.mailbox.sent_messages
  end
  
  def show
    klass = params[:copy] == "true" ? Mailbox::MessageCopy : Mailbox::Message
    @message = klass.find params[:id]
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
end
