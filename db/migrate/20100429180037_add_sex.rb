class AddSex < ActiveRecord::Migration
  def self.up
    add_column :people, :sex, :string
  end

  def self.down
    remove_column :people, :sex
  end
end
