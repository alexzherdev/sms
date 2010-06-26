# coding: utf-8

module Mailbox
  class Mailbox < ActiveRecord::Base
    SENT_FOLDER_ID = 100500
    TRASH_ID = 100600

    FOLDERS = { :inbox => "Входящие" }

    FOLDERS.each do |k, v|
      define_method k do
        self.folders.find_by_name v
      end
    end

    belongs_to :user
    has_many :sent_messages, :class_name => "Mailbox::Message", :conditions => { :deleted => MessageUtils::NOT_DELETED }, :order => "created_at DESC"
    has_many :folders, :class_name => "Mailbox::Folder"

    after_create :create_folders
    
    def sent
      { :id => SENT_FOLDER_ID, :name => "Отправленные" }
    end
    
    def trash
      { :id => TRASH_ID, :name => "Корзина" }
    end
    
    def trash_messages
      (Message.find_all_by_mailbox_id_and_deleted(self.id, MessageUtils::TRASHED) + MessageCopy.find(:all, :conditions => ["deleted = ? and folder_id in (?)", MessageUtils::TRASHED, self.folder_ids])).sort_by { |m| -m.created_at.to_i }
    end
    
    protected

    def create_folders
      FOLDERS.values.each do |name|
        self.folders.find_or_create_by_name(name)
      end
    end
  end
end