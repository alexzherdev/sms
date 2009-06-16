class CreateClassRooms < ActiveRecord::Migration
  def self.up
    create_table :class_rooms do |t|
      t.string :number

      t.timestamps
    end
  end

  def self.down
    drop_table :class_rooms
  end
end
