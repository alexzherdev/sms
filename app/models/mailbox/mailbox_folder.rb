module Mailbox
  class Folder < ActiveRecord::Base
    set_table_name "mailbox_folders"
    
    has_many :message_copies, :class_name => "Mailbox::MessageCopy", :foreign_key => "folder_id", :order => "created_at DESC", :conditions => { :deleted => MessageUtils::NOT_DELETED }

    validates_presence_of :name

    def unread_count
      message_copies.count(:conditions => { :status => MessageCopy::UNREAD })
    end
  end
end