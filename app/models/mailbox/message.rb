module Mailbox
  class Message < ActiveRecord::Base
    belongs_to :mailbox, :class_name => "Mailbox::Mailbox" 
    has_many :message_copies, :class_name => "Mailbox::MessageCopy"
    has_many :recipients, :through => :message_copies

    attr_accessor :to

    validates_presence_of :mailbox

    sanitize :subject
    sanitize :body

    before_create :set_defaults, :create_copies

    def recipients_string
      recipients.collect(&:full_name_abbr).join(", ")
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
    
    def created_at_full
      self.created_at.to_s(:message_full)
    end
    
    def folder
      self.mailbox.inbox.id
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
        message_copies.build(:recipient_id => recipient.id, :folder_id => recipient.mailbox.inbox.id, :status => MessageCopy::UNREAD)
      end
    end
  end
end