class Comment < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  belongs_to :user
  has_many :comments, :as => :parent, :dependent => :destroy, :class_name => "::Comment"
  has_many :attachments, :as => :parent, :dependent => :destroy, :class_name => "::Attachment"

  default_scope :order => "created_at DESC"

  def editable?(current_user)
    (current_user == self.user)||authorized?("comment")
  end

  alias_method :removable?, :editable?

end
