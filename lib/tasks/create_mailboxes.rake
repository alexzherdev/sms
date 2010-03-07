namespace :sms do
  task :create_mailboxes => :environment do
    load_models
    User.transaction do
      User.all.each do |user|
        if user.mailbox.blank?
          Mailbox::Mailbox.create :user_id => user.id
        end
      end
    end
  end
  
  task :create_mailbox_folders => :environment do
    load_models
    User.transaction do
      User.all.each do |user|
        unless user.mailbox.blank?
          user.mailbox.create_folders
        end
      end
    end
  end
  
  def load_models
    Dir.glob(File.join(RAILS_ROOT,'app','models','**','*.rb')).each do |file|
      require_dependency file
    end
  end
end