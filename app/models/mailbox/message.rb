module Mailbox
  
  class Message < ActiveRecord::Base
    
    include MessageUtils
    
    belongs_to :mailbox, :class_name => "Mailbox::Mailbox" 
    has_many :message_copies, :class_name => "Mailbox::MessageCopy"
    has_many :recipients, :through => :message_copies
    has_many :attachments, :as => :parent, :dependent => :destroy, :class_name => "::Attachment"


    attr_accessor :to

    validates_presence_of :mailbox
    validates_inclusion_of :deleted, :in => [ MessageUtils::NOT_DELETED, MessageUtils::TRASHED, MessageUtils::DELETED ]
    
    sanitize :subject
    sanitize :body

    before_create :set_defaults, :create_copies

    def recipients_string
      recipients.collect(&:full_name_abbr).join(", ")
    end

    def attachments_string
      self.attachments.collect { |t| t.name + "|" + t.url }.join("|")
    end

    def copy?
      false
    end
    
    def sender
      self.mailbox.user
    end
    
    def sender_full_name_abbr
      self.sender.full_name_abbr
    end

    def folder_id
      Mailbox::SENT_FOLDER_ID
    end
    
    def prepare_reply
      reply = Message.new :subject => format_reply_subject, :body => format_reply_body, :recipient_ids => recipient_ids
    end

    def prepare_reply_all
      reply = Message.new :subject => format_reply_subject, :body => format_reply_body, :recipient_ids => recipient_ids
    end
    
    protected

    def set_defaults
      if self.subject.blank?
        self.subject = "(Без темы)"
      end
    end

    def create_copies
      return if to.blank?
      to.split(",").each do |rec|
        recipient = User.find rec
        message_copies.build(:recipient_id => recipient.id, :folder_id => recipient.mailbox.inbox.id)
      end
    end

  end
end