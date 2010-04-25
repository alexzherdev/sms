class AddPatronymicToPeople < ActiveRecord::Migration
  def self.up
    add_column :people, :patronymic, :string
  end

  def self.down
    remove_column :people, :patronymic
  end
end
