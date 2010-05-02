class Comment < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :user
  has_many :comments, :as => :parent, :dependent => :destroy, :class_name => "::Comment"
  has_many :attachments, :as => :parent, :dependent => :destroy, :class_name => "::Attachment"

  default_scope :order => "created_at DESC"
end
