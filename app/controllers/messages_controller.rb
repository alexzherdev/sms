class MessagesController < ApplicationController
  before_filter :preload_message, :only => [:show, :reply, :reply_all, :forward]
  
  def index
    @users = User.all
    @messages = current_user.mailbox.sent_messages
    @message = Mailbox::Message.new
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
    @message = Mailbox::Message.new params[:message].merge(:mailbox_id => current_user.mailbox.id)
    process_file_uploads(@message)

    @message.save

    respond_to do |format|
      format.js do
        responds_to_parent do
          render :update do |page|
            page.replace_html "mailbox_link", link_to_mailbox
            page.call "Global.mailbox.showInboxFolder"
          end
        end          
      end
    end
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
      messages = Mailbox::MessageCopy.where("id in (?) and recipient_id = ?" , ids, current_user.id)
    else
      messages = Mailbox::Message.where("id in (?) and mailbox_id = ?", ids, current_user.mailbox.id)
    end
    [messages].flatten.each(&:delete!)
    render :nothing => true
  end
  
  def restore
    ids = params[:ids].split(",")
    copy = params[:copy].split(",")
    ids.each_with_index do |id, i|
      if copy[i] == "true"
        message = Mailbox::MessageCopy.where(:id => params[:id], :recipient_id => current_user.id).first
      else
        message = Mailbox::Message.where(:id => params[:id], :mailbox_id => current_user.mailbox.id).first
      end
      message.restore!
    end
    render :nothing => true
  end
  
  def destroy_attachment
    @attachment = Attachment.find params[:id]
    @att_id = @attachment.id
    @attachment.destroy
  end
  
  protected
  
  def preload_message
    if params[:copy] == "true"
      @message = Mailbox::MessageCopy.where(:id => params[:id], :recipient_id => current_user.id).first
    else
      @message = Mailbox::Message.where(:id => params[:id], :mailbox_id => current_user.mailbox.id).first
    end
  end

  def process_file_uploads(messages)
    (params[:attachment] || {}).each do |k, v|
      messages.attachments.build(:data => v)
    end
  end
end
