class CreateStudents < ActiveRecord::Migration
  def self.up
    add_column :people, :parent_email, :string
    add_column :people, :parent1_id, :integer
    add_column :people, :parent2_id, :integer
    add_column :people, :home_address, :string
    add_column :people, :student_group_id, :integer
  end

  def self.down
    remove_column :people, :parent_email
    remove_column :people, :parent1_id
    remove_column :people, :parent2_id
    remove_column :people, :home_address
    remove_column :people, :student_group_id
  end
end
