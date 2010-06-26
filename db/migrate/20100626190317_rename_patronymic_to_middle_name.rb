class RenamePatronymicToMiddleName < ActiveRecord::Migration
  def self.up
    rename_column :people, :patronymic, :middle_name
  end

  def self.down
    rename_column :people, :middle_name, :patronymic
  end
end
