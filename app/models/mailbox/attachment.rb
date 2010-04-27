class Attachment < ActiveRecord::Base
  belongs_to :parent, :polymorphic => true
  
  has_attached_file :data
  
  def url(*args)
    data.url(*args)
  end
  
  def name
    data_file_name
  end
  
  def content_type
    data_content_type
  end
  
  def file_size
    data_file_size
  end
  
end
