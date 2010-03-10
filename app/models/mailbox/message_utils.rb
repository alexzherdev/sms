module Mailbox
  module MessageUtils
    REPLY_REGEX = /Ответ \((.+)\)/
    
    def format_reply_subject
      re_index = self.subject.index("Ответ")
      if re_index != 0
        return "Ответ: #{self.subject}"
      else
        if self.subject.index("Ответ:") == 0
          return "Ответ (2):" + self.subject.sub("Ответ:", "")
        else
          num = REPLY_REGEX.match(self.subject)[1]
          return "Ответ (#{num + 1}):" + self.subject.sub(REPLY_REGEX, "")
        end
      end
    end
    
    def format_reply_body
      "<br/>" + "-" * 50 + "<br/><br/>" + self.body
    end
    
    def created_at_full
      self.created_at.to_s(:message_full)
    end
    
    def delete!
      if self.deleted
        self.destroy
      else
        self.update_attribute :deleted, true
      end
    end
    
    def restore!
      self.update_attribute :deleted, false
    end
  end
end