class CreateMarks < ActiveRecord::Migration
  def self.up
    create_table :marks do |t|
      t.datetime :date
      t.belongs_to :student
      t.integer :mark
      t.belongs_to :schedule_item
      t.belongs_to :modified_by_id
      
      t.timestamps
    end
  end

  def self.down
    drop_table :marks
  end
end
