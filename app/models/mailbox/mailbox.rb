module Mailbox
  class Mailbox < ActiveRecord::Base

    FOLDERS = { :inbox => "Входящие", :sent => "Отправленные", :trash => "Корзина" }

    FOLDERS.each do |k, v|
      define_method k do
        self.folders.find_by_name v
      end
    end

    belongs_to :user
    has_many :sent_messages, :class_name => "Mailbox::Message", :order => "created_at DESC"
    has_many :folders, :class_name => "Mailbox::Folder"

    after_create :create_folders

    protected

    def create_folders
      FOLDERS.values.each do |name|
        self.folders.find_or_create_by_name(name)
      end
    end
  end
end