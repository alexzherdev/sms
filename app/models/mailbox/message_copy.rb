module Mailbox
  class MessageCopy < ActiveRecord::Base
    include MessageUtils
    
    UNREAD = 0
    READ = 1

    belongs_to :message, :class_name => "Mailbox::Message"
    belongs_to :recipient, :class_name => "User"
    belongs_to :folder, :class_name => "Mailbox::Folder"
    has_many :attachments, :as => :parent, :dependent => :destroy, :class_name => "::Attachment"

    validates_inclusion_of :status, :in => [ UNREAD, READ ]
    validates_inclusion_of :deleted, :in => [ MessageUtils::NOT_DELETED, MessageUtils::TRASHED, MessageUtils::DELETED ]

    delegate :sender, :sender_full_name_abbr, :subject, :body, :recipients_string, :attachments_string, :to => :message

    def copy?
      true
    end

    def read!
      self.update_attribute :status, READ
    end
    
    def prepare_reply
      reply = Message.new :subject => format_reply_subject, :body => format_reply_body, :recipient_ids => [self.recipient_id]
    end
    
    def prepare_reply_all
      reply = Message.new :subject => format_reply_subject, :body => format_reply_body, :recipient_ids => self.message.recipient_ids - [self.recipient_id]
    end
  end
end