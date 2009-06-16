class CreateUsers < ActiveRecord::Migration
  def self.up
    add_column :people, :login, :string  
    add_column :people, :email, :string  
    add_column :people, :crypted_password, :string  
    add_column :people, :password_salt, :string  
    add_column :people, :persistence_token, :string  
    add_column :people, :blocked, :boolean, :default => false   
  end

  def self.down
    remove_column :people, :login
    remove_column :people, :email  
    remove_column :people, :crypted_password
    remove_column :people, :password_salt
    remove_column :people, :persistence_token
    remove_column :people, :blocked
    
  end
end
