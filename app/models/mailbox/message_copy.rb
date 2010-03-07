module Mailbox
  class MessageCopy < ActiveRecord::Base
    UNREAD = 0
    READ = 1

    belongs_to :message, :class_name => "Mailbox::Message"
    belongs_to :recipient, :class_name => "User"
    belongs_to :folder, :class_name => "Mailbox::Folder"

    validates_inclusion_of :status, :in => [ UNREAD, READ ]

    delegate :sender, :sender_full_name_abbr, :subject, :body, :recipients_string, :to => :message

    def copy?
      true
    end

    def read!
      self.update_attribute :status, READ
    end

    def created_at_full
      self.created_at.to_s(:message_full)
    end
  end
end