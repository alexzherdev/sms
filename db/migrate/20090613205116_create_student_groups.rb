class CreateStudentGroups < ActiveRecord::Migration
  def self.up
    create_table :student_groups do |t|
      t.integer :year
      t.string :letter
      t.timestamps
    end
  end
  
  def self.down
    drop_table :student_groups
  end
end
