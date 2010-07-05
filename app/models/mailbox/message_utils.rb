# coding: utf-8

module Mailbox
  module MessageUtils
    NOT_DELETED = 0
    TRASHED = 1
    DELETED = 2
    
    REPLY_REGEX = /Ответ \((.+)\)/
    FORWARD_REGEX = /Пересланное \((.+)\)/
    
    def uid
      "#{self.class.name}_#{id}"
    end

    def format_subject(prefix, regex)
      re_index = self.subject.index(prefix)
      if re_index != 0
        return "#{prefix}: #{self.subject}"
      else
        if self.subject.index("#{prefix}:") == 0
          return "#{prefix} (2):" + self.subject.sub("#{prefix}:", "")
        else
          num = regex.match(self.subject)[1]
          return "#{prefix} (#{num + 1}):" + self.subject.sub(regex, "")
        end
      end
    end
    
    def format_reply_subject
      format_subject("Ответ", REPLY_REGEX)
    end
    
    def format_reply_body
      "<br/>" + "-" * 50 + "<br/><br/>" + self.body
    end
    
    def format_forward_subject
      format_subject("Пересланное", FORWARD_REGEX)      
    end
    
    def format_forward_body
      "<br/>" + "-" * 50 + "<br/><br/>" + self.body
    end
    
    def prepare_forward
      forward = Message.new :subject => format_forward_subject, :body => format_forward_body
    end
    
    def created_at_full
      self.created_at.to_s(:message_full)
    end
    
    def delete!
      if self.deleted == TRASHED
        self.update_attribute :deleted, DELETED
      else
        self.update_attribute :deleted, TRASHED
      end
    end
    
    def restore!
      self.update_attribute :deleted, false
    end
  end
end